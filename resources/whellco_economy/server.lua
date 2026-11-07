local playerAccounts = {}
local lastRequest = {}
local activeJobs = {}
local jobCooldowns = {}

local function getIdentifier(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')

    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'steam')
    end

    return identifier
end

local function canRequest(source)
    if type(source) ~= 'number' or source <= 0 then
        return false
    end

    local now = GetGameTimer()

    if now - (lastRequest[source] or 0) < 1000 then
        return false
    end

    lastRequest[source] = now

    return true
end

local function getLevel(xp)
    local level = 1

    for index, threshold in ipairs(Config.LevelThresholds) do
        if xp >= threshold then
            level = index
        end
    end

    return level
end

local function getAccount(source)
    local identifier = getIdentifier(source)

    if not identifier then
        return nil
    end

    return playerAccounts[identifier]
end

local function sendAccount(source)
    local account = getAccount(source)

    if not account then
        return
    end

    TriggerClientEvent('whellco_economy:updateAccount', source, {
        cash = account.cash,
        bank = account.bank,
        xp = account.xp,
        level = account.level,
        transactions = account.transactions
    })
end

AddEventHandler('playerConnecting', function(_, _, deferrals)
    local source = source
    local identifier = getIdentifier(source)

    deferrals.defer()
    Wait(0)
    deferrals.update('Loading your account…')

    if not identifier then
        deferrals.done('Unable to identify your account.')
        return
    end

    local existing = MySQL.single.await(
        'SELECT cash, bank, xp, level FROM whellco_players WHERE identifier = ? LIMIT 1',
        { identifier }
    )

    if not existing then
        MySQL.insert.await(
            [[
                INSERT INTO whellco_players
                    (identifier, player_name, cash, bank, xp, level)
                VALUES (?, ?, ?, ?, 0, 1)
            ]],
            { identifier, GetPlayerName(source) or 'Unknown Player', Config.StartingCash, Config.StartingBank }
        )

        existing = {
            cash = Config.StartingCash,
            bank = Config.StartingBank,
            xp = 0,
            level = 1
        }
    end

    local transactions = MySQL.query.await(
        [[
            SELECT type, amount, balance_after, description, created_at
            FROM whellco_transactions
            WHERE identifier = ?
            ORDER BY created_at DESC
            LIMIT 25
        ]],
        { identifier }
    ) or {}

    playerAccounts[identifier] = {
        identifier = identifier,
        cash = tonumber(existing.cash) or 0,
        bank = tonumber(existing.bank) or 0,
        xp = tonumber(existing.xp) or 0,
        level = tonumber(existing.level) or 1,
        transactions = transactions
    }

    deferrals.done()
end)

RegisterNetEvent('whellco_economy:requestAccount', function()
    local source = source

    if not canRequest(source) then
        return
    end

    sendAccount(source)
end)

RegisterNetEvent('whellco_economy:openShop', function(shopId)
    local source = source

    if not canRequest(source) then
        return
    end

    local shop = Config.Shops[shopId]

    if not shop then
        return
    end

    local ped = GetPlayerPed(source)

    if #(GetEntityCoords(ped) - shop.coords) > 5.0 then
        return
    end

    local account = getAccount(source)

    if not account then
        return
    end

    SetNuiFocus(source, true, true)

    TriggerClientEvent('whellco_economy:openShop', source, {
        shopId = shopId,
        label = shop.label,
        items = shop.items,
        cash = account.cash,
        bank = account.bank
    })
end)

RegisterNuiCallback('closeShop', function(_, cb)
    local source = source

    SetNuiFocus(source, false, false)
    cb({ ok = true })
end)

RegisterNuiCallback('purchaseItem', function(data, cb)
    local source = source
    local account = getAccount(source)

    if not account then
        cb({ ok = false, error = 'Account unavailable.' })
        return
    end

    if not canRequest(source) then
        cb({ ok = false, error = 'Please wait before trying again.' })
        return
    end

    local shop = Config.Shops[data.shopId]
    local item = shop and shop.items[data.itemId]

    if not item then
        cb({ ok = false, error = 'That item is unavailable.' })
        return
    end

    local ped = GetPlayerPed(source)

    if #(GetEntityCoords(ped) - shop.coords) > 5.0 then
        cb({ ok = false, error = 'You are too far from the shop.' })
        return
    end

    local quantity = tonumber(data.quantity) or 0

    if quantity < 1 or quantity > 10 then
        cb({ ok = false, error = 'Invalid quantity.' })
        return
    end

    local total = item.price * quantity

    if account.cash < total then
        cb({ ok = false, error = 'You do not have enough cash.' })
        return
    end

    local success = MySQL.transaction.await({
        {
            query = 'UPDATE whellco_players SET cash = cash - ? WHERE identifier = ? AND cash >= ?',
            values = { total, account.identifier, total }
        },
        {
            query = [[
                INSERT INTO whellco_inventory (identifier, item_id, quantity)
                VALUES (?, ?, ?)
                ON DUPLICATE KEY UPDATE quantity = quantity + VALUES(quantity)
            ]],
            values = { account.identifier, data.itemId, quantity }
        },
        {
            query = [[
                INSERT INTO whellco_transactions
                    (identifier, type, amount, balance_after, description)
                VALUES (?, 'purchase', ?, ?, ?)
            ]],
            values = {
                account.identifier,
                total,
                account.cash - total,
                ('Purchased %dx %s'):format(quantity, item.label)
            }
        }
    })

    if not success then
        cb({ ok = false, error = 'Purchase failed. Please try again.' })
        return
    end

    account.cash = account.cash - total
    account.xp = account.xp + (item.xp * quantity)

    local newLevel = getLevel(account.xp)
    local levelledUp = newLevel > account.level

    account.level = newLevel

    MySQL.update.await(
        'UPDATE whellco_players SET cash = ?, xp = ?, level = ? WHERE identifier = ?',
        { account.cash, account.xp, account.level, account.identifier }
    )

    if levelledUp then
        TriggerClientEvent('whellco_economy:levelUp', source, account.level)
    end

    sendAccount(source)

    cb({
        ok = true,
        receipt = {
            item = item.label,
            quantity = quantity,
            total = total,
            cash = account.cash,
            xp = account.xp,
            level = account.level
        }
    })
end)

RegisterNetEvent('whellco_economy:startJob', function(jobId)
    local source = source

    if not canRequest(source) then
        return
    end

    local job = Config.Jobs[jobId]

    if not job then
        return
    end

    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    if activeJobs[identifier] then
        TriggerClientEvent('whellco_economy:notify', source, 'You are already on a job.')
        return
    end

    local now = GetGameTimer()

    if now - (jobCooldowns[identifier] or 0) < job.cooldown then
        TriggerClientEvent('whellco_economy:notify', source, 'You need to wait before starting this job again.')
        return
    end

    local ped = GetPlayerPed(source)

    if #(GetEntityCoords(ped) - job.start) > 10.0 then
        TriggerClientEvent('whellco_economy:notify', source, 'You are too far from the job start location.')
        return
    end

    activeJobs[identifier] = {
        id = jobId,
        startedAt = now
    }

    TriggerClientEvent('whellco_economy:jobStarted', source, {
        id = jobId,
        label = job.label
    })
end)

RegisterNetEvent('whellco_economy:completeJob', function()
    local source = source

    if not canRequest(source) then
        return
    end

    local identifier = getIdentifier(source)
    local active = activeJobs[identifier]

    if not active then
        TriggerClientEvent('whellco_economy:notify', source, 'You do not have an active job.')
        return
    end

    local job = Config.Jobs[active.id]

    if not job then
        activeJobs[identifier] = nil
        return
    end

    local ped = GetPlayerPed(source)

    if #(GetEntityCoords(ped) - job.complete) > 10.0 then
        TriggerClientEvent('whellco_economy:notify', source, 'Go to the job completion point.')
        return
    end

    local account = getAccount(source)

    if not account then
        return
    end

    local payout = job.payout
    local xpGain = job.xp

    account.bank = account.bank + payout
    account.xp = account.xp + xpGain

    local newLevel = getLevel(account.xp)
    local levelledUp = newLevel > account.level

    account.level = newLevel

    MySQL.transaction.await({
        {
            query = 'UPDATE whellco_players SET bank = ?, xp = ?, level = ? WHERE identifier = ?',
            values = { account.bank, account.xp, account.level, identifier }
        },
        {
            query = [[
                INSERT INTO whellco_transactions
                    (identifier, type, amount, balance_after, description)
                VALUES (?, 'wage', ?, ?, ?)
            ]],
            values = {
                identifier,
                payout,
                account.bank,
                ('Completed %s job'):format(job.label)
            }
        }
    })

    jobCooldowns[identifier] = GetGameTimer()
    activeJobs[identifier] = nil

    if levelledUp then
        TriggerClientEvent('whellco_economy:levelUp', source, account.level)
    end

    sendAccount(source)

    TriggerClientEvent('whellco_economy:notify', source, ('Job complete! %s%d added to bank.'):format(Config.Currency, payout))
    TriggerClientEvent('whellco_economy:jobCompleted', source)
end)

RegisterCommand('cash', function(source)
    if source == 0 then
        return
    end

    local account = getAccount(source)

    if account then
        TriggerClientEvent('whellco_economy:notify', source, ('Cash: %s%d | Bank: %s%d'):format(Config.Currency, account.cash, Config.Currency, account.bank))
    end
end, false)

RegisterCommand('bank', function(source)
    if source == 0 then
        return
    end

    local account = getAccount(source)

    if account then
        TriggerClientEvent('whellco_economy:notify', source, ('Bank balance: %s%d'):format(Config.Currency, account.bank))
    end
end, false)

AddEventHandler('playerDropped', function()
    local identifier = getIdentifier(source)

    if identifier then
        playerAccounts[identifier] = nil
        activeJobs[identifier] = nil
    end

    lastRequest[source] = nil
end)
