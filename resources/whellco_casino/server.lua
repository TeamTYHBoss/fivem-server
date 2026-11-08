local activeMemberships = {}
local lastGameRequest = {}

local function getIdentifier(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')

    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'steam')
    end

    return identifier
end

local function canAct(source)
    if type(source) ~= 'number' or source <= 0 then
        return false
    end

    local now = GetGameTimer()

    if now - (lastGameRequest[source] or 0) < 750 then
        return false
    end

    lastGameRequest[source] = now

    return true
end

local function getMembership(source)
    local identifier = getIdentifier(source)

    if not identifier then
        return Config.Memberships.free
    end

    local cached = activeMemberships[identifier]

    if cached then
        return cached
    end

    local row = MySQL.single.await(
        [[
            SELECT tier
            FROM whellco_casino_memberships
            WHERE character_id = (
                SELECT character_id FROM whellco_players WHERE identifier = ? ORDER BY created_at DESC LIMIT 1
            )
            LIMIT 1
        ]],
        { identifier }
    )

    local tier = row and row.tier or 'free'
    local membership = Config.Memberships[tier] or Config.Memberships.free

    activeMemberships[identifier] = {
        tier = tier,
        label = membership.label,
        winRateMultiplier = membership.winRateMultiplier,
        discount = membership.discount,
        garageSpaces = membership.garageSpaces
    }

    return activeMemberships[identifier]
end

local function getAccount(source)
    local identifier = getIdentifier(source)

    if not identifier then
        return nil
    end

    return MySQL.single.await(
        [[
            SELECT character_id, cash, bank
            FROM whellco_players
            WHERE identifier = ?
            ORDER BY created_at DESC
            LIMIT 1
        ]],
        { identifier }
    )
end

local function adjustCash(account, amount, description)
    if amount > 0 then
        local updated = MySQL.update.await(
            'UPDATE whellco_players SET cash = cash + ? WHERE character_id = ?',
            { amount, account.character_id }
        )

        if not updated or updated == 0 then
            return false
        end
    elseif amount < 0 then
        local cost = math.abs(amount)

        local updated = MySQL.update.await(
            'UPDATE whellco_players SET cash = cash - ? WHERE character_id = ? AND cash >= ?',
            { cost, account.character_id, cost }
        )

        if not updated or updated == 0 then
            return false
        end
    end

    if description then
        MySQL.insert.await(
            [[
                INSERT INTO whellco_casino_transactions
                    (character_id, type, amount, description)
                VALUES (?, ?, ?, ?)
            ]],
            { account.character_id, amount >= 0 and 'casino_win' or 'casino_spend', amount, description }
        )
    end

    return true
end

local function recordGame(account, game, bet, payout, result)
    MySQL.insert.await(
        [[
            INSERT INTO whellco_casino_game_history
                (character_id, game, bet, payout, result)
            VALUES (?, ?, ?, ?, ?)
        ]],
        { account.character_id, game, bet or 0, payout or 0, result or '' }
    )
end

local function sendCasinoData(source)
    local account = getAccount(source)
    local membership = getMembership(source)

    if not account then
        return
    end

    local penthouse = MySQL.single.await(
        [[
            SELECT lighting, flooring, furniture, security
            FROM whellco_casino_penthouses
            WHERE character_id = ?
            LIMIT 1
        ]],
        { account.character_id }
    ) or {}

    local garageSpaces = MySQL.query.await(
        [[
            SELECT space_type, purchased_at
            FROM whellco_casino_garage_spaces
            WHERE character_id = ?
            ORDER BY purchased_at ASC
        ]],
        { account.character_id }
    ) or {}

    TriggerClientEvent('whellco_casino:openMenu', source, {
        cash = account.cash,
        bank = account.bank,
        membership = membership,
        penthouse = penthouse,
        garageSpaces = garageSpaces,
        memberships = Config.Memberships,
        penthouseOptions = Config.PenthouseOptions,
        garageSpaces = Config.GarageSpaces,
        slotBetOptions = Config.SlotBetOptions,
        wheelSpinCost = Config.WheelSpinCost
    })
end

RegisterNetEvent('whellco_casino:openMenu', function()
    local source = source

    if not canAct(source) then
        return
    end

    sendCasinoData(source)
end)

RegisterNetEvent('whellco_casino:closeMenu', function()
    TriggerClientEvent('whellco_casino:closeMenu', source)
end)

RegisterNetEvent('whellco_casino:purchaseMembership', function(tier)
    local source = source

    if not canAct(source) then
        return
    end

    local membership = Config.Memberships[tier]
    local account = getAccount(source)

    if not membership or not account then
        return
    end

    if tier == 'free' then
        TriggerClientEvent('whellco_casino:notify', source, 'You already have the free membership.')
        return
    end

    local current = getMembership(source)

    if current.tier == tier then
        TriggerClientEvent('whellco_casino:notify', source, 'You already own this membership.')
        return
    end

    if current.tier == 'vip' then
        TriggerClientEvent('whellco_casino:notify', source, 'You already own the highest membership.')
        return
    end

    local price = math.floor(membership.price * (1 - current.discount))

    if not adjustCash(account, -price, ('Purchased %s'):format(membership.label)) then
        TriggerClientEvent('whellco_casino:notify', source, 'You do not have enough cash.')
        return
    end

    MySQL.query.await(
        [[
            INSERT INTO whellco_casino_memberships
                (character_id, tier)
            VALUES (?, ?)
            ON DUPLICATE KEY UPDATE tier = VALUES(tier)
        ]],
        { account.character_id, tier }
    )

    activeMemberships[getIdentifier(source)] = nil

    TriggerClientEvent('whellco_casino:notify', source, ('%s activated.'):format(membership.label))

    sendCasinoData(source)
end)

RegisterNetEvent('whellco_casino:spinSlots', function(bet)
    local source = source

    if not canAct(source) then
        return
    end

    bet = math.floor(tonumber(bet) or 0)
    local account = getAccount(source)
    local membership = getMembership(source)

    if not account or not membership then
        return
    end

    local validBet = false

    for _, allowedBet in ipairs(Config.SlotBetOptions) do
        if allowedBet == bet then
            validBet = true
            break
        end
    end

    if not validBet then
        return
    end

    if not adjustCash(account, -bet, 'Slot machine bet') then
        TriggerClientEvent('whellco_casino:notify', source, 'You do not have enough cash.')
        return
    end

    local winChance = math.min(0.95, Config.SlotBaseWinChance * membership.winRateMultiplier)
    local reels = {}

    for _ = 1, 3 do
        reels[#reels + 1] = Config.SlotSymbols[math.random(1, #Config.SlotSymbols)]
    end

    local payout = 0
    local result = 'Loss'

    if math.random() <= winChance then
        local symbol = reels[math.random(1, 3)]
        reels = { symbol, symbol, symbol }

        payout = math.floor(bet * Config.SlotPayouts[symbol])
        result = ('Win: %s x%d'):format(symbol, Config.SlotPayouts[symbol])

        adjustCash(account, payout, ('Slot machine win: %s'):format(symbol))
    end

    recordGame(account, 'slots', bet, payout, result)

    TriggerClientEvent('whellco_casino:slotResult', source, {
        reels = reels,
        payout = payout,
        result = result
    })

    sendCasinoData(source)
end)

RegisterNetEvent('whellco_casino:spinWheel', function()
    local source = source

    if not canAct(source) then
        return
    end

    local account = getAccount(source)
    local membership = getMembership(source)

    if not account or not membership then
        return
    end

    local cost = math.floor(Config.WheelSpinCost * (1 - membership.discount))

    if not adjustCash(account, -cost, 'Wheel spin') then
        TriggerClientEvent('whellco_casino:notify', source, 'You do not have enough cash.')
        return
    end

    local totalWeight = 0

    for _, prize in ipairs(Config.WheelPrizes) do
        totalWeight = totalWeight + prize.weight
    end

    local roll = math.random() * totalWeight
    local selected = Config.WheelPrizes[1]

    for _, prize in ipairs(Config.WheelPrizes) do
        roll = roll - prize.weight

        if roll <= 0 then
            selected = prize
            break
        end
    end

    local payout = selected.amount

    if payout > 0 then
        adjustCash(account, payout, ('Wheel spin prize: %s'):format(selected.label))
    end

    recordGame(account, 'wheel', cost, payout, selected.label)

    TriggerClientEvent('whellco_casino:wheelResult', source, {
        label = selected.label,
        amount = payout
    })

    sendCasinoData(source)
end)

RegisterNetEvent('whellco_casino:purchasePenthouse', function()
    local source = source

    if not canAct(source) then
        return
    end

    local account = getAccount(source)
    local membership = getMembership(source)

    if not account or not membership then
        return
    end

    local existing = MySQL.single.await(
        [[
            SELECT character_id
            FROM whellco_casino_penthouses
            WHERE character_id = ?
            LIMIT 1
        ]],
        { account.character_id }
    )

    if existing then
        TriggerClientEvent('whellco_casino:notify', source, 'You already own a penthouse.')
        return
    end

    local price = math.floor(Config.Penthouse.price * (1 - membership.discount))

    if not adjustCash(account, -price, 'Purchased casino penthouse') then
        TriggerClientEvent('whellco_casino:notify', source, 'You do not have enough cash.')
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_casino_penthouses
                (character_id)
            VALUES (?)
        ]],
        { account.character_id }
    )

    TriggerClientEvent('whellco_casino:notify', source, 'Penthouse purchased.')

    sendCasinoData(source)
end)

RegisterNetEvent('whellco_casino:customisePenthouse', function(optionType, optionId)
    local source = source

    if not canAct(source) then
        return
    end

    local account = getAccount(source)
    local membership = getMembership(source)

    if not account or not membership then
        return
    end

    local optionGroup = Config.PenthouseOptions[optionType]
    local option = optionGroup and optionGroup.options[optionId]

    if not option then
        return
    end

    local owned = MySQL.single.await(
        [[
            SELECT character_id
            FROM whellco_casino_penthouses
            WHERE character_id = ?
            LIMIT 1
        ]],
        { account.character_id }
    )

    if not owned then
        TriggerClientEvent('whellco_casino:notify', source, 'You need to buy a penthouse first.')
        return
    end

    local price = math.floor(option.price * (1 - membership.discount))

    if not adjustCash(account, -price, ('Penthouse customisation: %s'):format(option.label)) then
        TriggerClientEvent('whellco_casino:notify', source, 'You do not have enough cash.')
        return
    end

    MySQL.update.await(
        ('UPDATE whellco_casino_penthouses SET %s = ? WHERE character_id = ?'):format(optionType),
        { optionId, account.character_id }
    )

    TriggerClientEvent('whellco_casino:notify', source, ('Penthouse updated: %s.'):format(option.label))

    sendCasinoData(source)
end)

RegisterNetEvent('whellco_casino:purchaseGarageSpace', function(spaceType)
    local source = source

    if not canAct(source) then
        return
    end

    local account = getAccount(source)
    local membership = getMembership(source)
    local space = Config.GarageSpaces[spaceType]

    if not account or not membership or not space then
        return
    end

    local owned = MySQL.single.await(
        [[
            SELECT id
            FROM whellco_casino_garage_spaces
            WHERE character_id = ? AND space_type = ?
            LIMIT 1
        ]],
        { account.character_id, spaceType }
    )

    if owned then
        TriggerClientEvent('whellco_casino:notify', source, 'You already own this garage space.')
        return
    end

    local price = math.floor(space.price * (1 - membership.discount))

    if not adjustCash(account, -price, ('Purchased %s'):format(space.label)) then
        TriggerClientEvent('whellco_casino:notify', source, 'You do not have enough cash.')
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_casino_garage_spaces
                (character_id, space_type)
            VALUES (?, ?)
        ]],
        { account.character_id, spaceType }
    )

    TriggerClientEvent('whellco_casino:notify', source, ('%s purchased.'):format(space.label))

    sendCasinoData(source)
end)

AddEventHandler('playerDropped', function()
    local identifier = getIdentifier(source)

    if identifier then
        activeMemberships[identifier] = nil
        lastGameRequest[source] = nil
    end
end)
