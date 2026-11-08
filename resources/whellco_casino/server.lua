local QBCore = exports['qb-core']:GetCoreObject()

local activeMemberships = {}
local lastGameRequest = {}

local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
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
    local Player = getQbPlayer(source)

    if not Player then
        return Config.Memberships.free
    end

    local citizenId = Player.PlayerData.citizenid
    local cached = activeMemberships[citizenId]

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
        { Player.PlayerData.identifier }
    )

    local tier = row and row.tier or 'free'
    local membership = Config.Memberships[tier] or Config.Memberships.free

    activeMemberships[citizenId] = {
        tier = tier,
        label = membership.label,
        winRateMultiplier = membership.winRateMultiplier,
        discount = membership.discount,
        garageSpaces = membership.garageSpaces
    }

    return activeMemberships[citizenId]
end

local function getAccount(source)
    local Player = getQbPlayer(source)

    if not Player then
        return nil
    end

    return MySQL.single.await(
        [[
            SELECT character_id
            FROM whellco_players
            WHERE identifier = ?
            ORDER BY created_at DESC
            LIMIT 1
        ]],
        { Player.PlayerData.identifier }
    )
end

local function spendCash(source, amount, description)
    local Player = getQbPlayer(source)

    if not Player then
        return false
    end

    amount = math.floor(tonumber(amount) or 0)

    if amount <= 0 then
        return false
    end

    if Player.Functions.GetMoney('cash') < amount then
        return false
    end

    if not Player.Functions.RemoveMoney('cash', amount, description or 'WhellCo Casino') then
        return false
    end

    local account = getAccount(source)

    if account then
        MySQL.insert.await(
            [[
                INSERT INTO whellco_casino_transactions
                    (character_id, type, amount, description)
                VALUES (?, 'casino_spend', ?, ?)
            ]],
            { account.character_id, -amount, description or 'WhellCo Casino' }
        )
    end

    return true
end

local function giveCash(source, amount, description)
    local Player = getQbPlayer(source)

    if not Player then
        return false
    end

    amount = math.floor(tonumber(amount) or 0)

    if amount <= 0 then
        return false
    end

    if not Player.Functions.AddMoney('cash', amount, description or 'WhellCo Casino') then
        return false
    end

    local account = getAccount(source)

    if account then
        MySQL.insert.await(
            [[
                INSERT INTO whellco_casino_transactions
                    (character_id, type, amount, description)
                VALUES (?, 'casino_win', ?, ?)
            ]],
            { account.character_id, amount, description or 'WhellCo Casino' }
        )
    end

    return true
end

local function recordGame(source, game, bet, payout, result)
    local account = getAccount(source)

    if not account then
        return
    end

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
    local Player = getQbPlayer(source)
    local account = getAccount(source)
    local membership = getMembership(source)

    if not Player or not account then
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
        cash = Player.Functions.GetMoney('cash'),
        bank = Player.Functions.GetMoney('bank'),
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
    local current = getMembership(source)

    if not membership or not current then
        return
    end

    if tier == 'free' then
        TriggerClientEvent('QBCore:Notify', source, 'You already have the free membership.', 'error')
        return
    end

    if current.tier == tier then
        TriggerClientEvent('QBCore:Notify', source, 'You already own this membership.', 'error')
        return
    end

    if current.tier == 'vip' then
        TriggerClientEvent('QBCore:Notify', source, 'You already own the highest membership.', 'error')
        return
    end

    local price = math.floor(membership.price * (1 - current.discount))

    if not spendCash(source, price, ('Purchased %s'):format(membership.label)) then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have enough cash.', 'error')
        return
    end

    local account = getAccount(source)

    if not account then
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

    local Player = getQbPlayer(source)

    if Player then
        activeMemberships[Player.PlayerData.citizenid] = nil
    end

    TriggerClientEvent('QBCore:Notify', source, ('%s activated.'):format(membership.label), 'success')

    sendCasinoData(source)
end)

RegisterNetEvent('whellco_casino:spinSlots', function(bet)
    local source = source

    if not canAct(source) then
        return
    end

    bet = math.floor(tonumber(bet) or 0)
    local membership = getMembership(source)

    if not membership then
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

    if not spendCash(source, bet, 'Slot machine bet') then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have enough cash.', 'error')
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

        giveCash(source, payout, ('Slot machine win: %s'):format(symbol))
    end

    recordGame(source, 'slots', bet, payout, result)

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

    local membership = getMembership(source)

    if not membership then
        return
    end

    local cost = math.floor(Config.WheelSpinCost * (1 - membership.discount))

    if not spendCash(source, cost, 'Wheel spin') then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have enough cash.', 'error')
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
        giveCash(source, payout, ('Wheel spin prize: %s'):format(selected.label))
    end

    recordGame(source, 'wheel', cost, payout, selected.label)

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
        TriggerClientEvent('QBCore:Notify', source, 'You already own a penthouse.', 'error')
        return
    end

    local price = math.floor(Config.Penthouse.price * (1 - membership.discount))

    if not spendCash(source, price, 'Purchased casino penthouse') then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have enough cash.', 'error')
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

    TriggerClientEvent('QBCore:Notify', source, 'Penthouse purchased.', 'success')

    sendCasinoData(source)
end)

RegisterNetEvent('whellco_casino:customisePenthouse', function(optionType, optionId)
    local source = source

    if not canAct(source) then
        return
    end

    local account = getAccount(source)
    local membership = getMembership(source)
    local optionGroup = Config.PenthouseOptions[optionType]
    local option = optionGroup and optionGroup.options[optionId]

    if not account or not membership or not option then
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
        TriggerClientEvent('QBCore:Notify', source, 'You need to buy a penthouse first.', 'error')
        return
    end

    local price = math.floor(option.price * (1 - membership.discount))

    if not spendCash(source, price, ('Penthouse customisation: %s'):format(option.label)) then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have enough cash.', 'error')
        return
    end

    MySQL.update.await(
        ('UPDATE whellco_casino_penthouses SET %s = ? WHERE character_id = ?'):format(optionType),
        { optionId, account.character_id }
    )

    TriggerClientEvent('QBCore:Notify', source, ('Penthouse updated: %s.'):format(option.label), 'success')

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
        TriggerClientEvent('QBCore:Notify', source, 'You already own this garage space.', 'error')
        return
    end

    local price = math.floor(space.price * (1 - membership.discount))

    if not spendCash(source, price, ('Purchased %s'):format(space.label)) then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have enough cash.', 'error')
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

    TriggerClientEvent('QBCore:Notify', source, ('%s purchased.'):format(space.label), 'success')

    sendCasinoData(source)
end)

AddEventHandler('playerDropped', function()
    local Player = getQbPlayer(source)

    if Player then
        activeMemberships[Player.PlayerData.citizenid] = nil
    end

    lastGameRequest[source] = nil
end)
