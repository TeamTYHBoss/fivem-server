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
    local characterId = playerAccounts[identifier] and playerAccounts[identifier].characterId

    if not identifier or not characterId then
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

local function getInventoryItems(characterId)
    return MySQL.query.await(
        [[
            SELECT item_id, quantity
            FROM whellco_inventory
            WHERE character_id = ? AND quantity > 0
            ORDER BY item_id ASC
        ]],
        { characterId }
    ) or {}
end

local function sendInventory(source)
    local account = getAccount(source)

    if not account then
        return
    end

    local items = getInventoryItems(account.characterId)
    local inventory = {}

    for _, row in ipairs(items) do
        local item = nil

        for _, shop in pairs(Config.Shops) do
            if shop.items[row.item_id] then
                item = shop.items[row.item_id]
                break
            end
        end

        if item then
            inventory[#inventory + 1] = {
                id = row.item_id,
                label = item.label,
                description = item.description or '',
                quantity = row.quantity,
                usable = item.usable or false
            }
        end
    end

    TriggerClientEvent('whellco_economy:openInventory', source, {
        items = inventory
    })
end

RegisterNetEvent('whellco_economy:characterSelected', function(characterId)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier or not characterId then
        return
    end

    local existing = MySQL.single.await(
        [[
            SELECT cash, bank, xp, level
            FROM whellco_players
            WHERE character_id = ?
            LIMIT 1
        ]],
        { characterId }
    )

    if not existing then
        MySQL.insert.await(
            [[
                INSERT INTO whellco_players
                    (character_id, identifier, player_name, cash, bank, xp, level)
                VALUES (?, ?, ?, ?, ?, 0, 1)
            ]],
            { characterId, identifier, GetPlayerName(source) or 'Unknown Player', Config.StartingCash, Config.StartingBank }
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
            WHERE character_id = ?
            ORDER BY created_at DESC
            LIMIT 25
        ]],
        { characterId }
    ) or {}

    playerAccounts[identifier] = {
        characterId = characterId,
        identifier = identifier,
        cash = tonumber(existing.cash) or 0,
        bank = tonumber(existing.bank) or 0,
        xp = tonumber(existing.xp) or 0,
        level = tonumber(existing.level) or 1,
        transactions = transactions
    }

    sendAccount(source)
end)

RegisterNetEvent('whellco_economy:requestAccount', function()
    local source = source

    if not canRequest(source) then
        return
    end

    sendAccount(source)
end)

RegisterNetEvent('whellco_economy:openInventory', function()
    local source = source

    if not canRequest(source) then
        return
    end

    sendInventory(source)
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
        cb({ ok = false, error = 'Select a character first.' })
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
            query = 'UPDATE whellco_players SET cash = cash - ? WHERE character_id = ? AND cash >= ?',
            values = { total, account.characterId, total }
        },
        {
            query = [[
                INSERT INTO whellco_inventory (character_id, item_id, quantity)
                VALUES (?, ?, ?)
                ON DUPLICATE KEY UPDATE quantity = quantity + VALUES(quantity)
            ]],
            values = { account.characterId, data.itemId, quantity }
        },
        {
            query = [[
                INSERT INTO whellco_transactions
                    (character_id, type, amount, balance_after, description)
                VALUES (?, 'purchase', ?, ?, ?)
            ]],
            values = {
                account.characterId,
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
        'UPDATE whellco_players SET cash = ?, xp = ?, level = ? WHERE character_id = ?',
        { account.cash, account.xp, account.level, account.characterId }
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

RegisterNuiCallback('useItem', function(data, cb)
    local source = source
    local account = getAccount(source)

    if not account then
        cb({ ok = false, error = 'Select a character first.' })
        return
    end

    if not canRequest(source) then
        cb({ ok = false, error = 'Please wait before trying again.' })
        return
    end

    local itemId = data.itemId
    local item = nil

    for _, shop in pairs(Config.Shops) do
        if shop.items[itemId] then
            item = shop.items[itemId]
            break
        end
    end

    if not item or not item.usable then
        cb({ ok = false, error = 'That item cannot be used.' })
        return
    end

    local updated = MySQL.update.await(
        [[
            UPDATE whellco_inventory
            SET quantity = quantity - 1
            WHERE character_id = ? AND item_id = ? AND quantity > 0
        ]],
        { account.characterId, itemId }
    )

    if not updated or updated == 0 then
        cb({ ok = false, error = 'You do not have that item.' })
        return
    end

    TriggerClientEvent('whellco_economy:useItem', source, {
        id = itemId,
        label = item.label
    })

    sendInventory(source)

    cb({ ok = true })
end)

RegisterNetEvent('whellco_economy:openJobBoard', function()
    local source = source

    if not canRequest(source) then
        return
    end

    local ped = GetPlayerPed(source)

    if #(GetEntityCoords(ped) - Config.JobBoard.coords) > 10.0 then
        return
    end

    local account = getAccount(source)

    if not account then
        return
    end

    local jobs = {}

    for id, job in pairs(Config.Jobs) do
        local remaining = math.max(0, job.cooldown - (GetGameTimer() - (jobCooldowns[account.characterId] or 0)))

        jobs[#jobs + 1] = {
            id = id,
            label = job.label,
            payout = job.payout,
            xp = job.xp,
            cooldownRemaining = remaining
        }
    end

    TriggerClientEvent('whellco_economy:openJobBoard', source, {
        jobs = jobs
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

    local account = getAccount(source)

    if not account then
        return
    end

    if activeJobs[account.characterId] then
        TriggerClientEvent('whellco_economy:notify', source, 'You are already on a job.')
        return
    end

    local now = GetGameTimer()

    if now - (jobCooldowns[account.characterId] or 0) < job.cooldown then
        TriggerClientEvent('whellco_economy:notify', source, 'You need to wait before starting this job again.')
        return
    end

    local ped = GetPlayerPed(source)

    if #(GetEntityCoords(ped) - job.start) > 10.0 then
        TriggerClientEvent('whellco_economy:notify', source, 'You are too far from the job start location.')
        return
    end

    activeJobs[account.characterId] = {
        id = jobId,
        startedAt = now,
        routeIndex = 1
    }

    TriggerClientEvent('whellco_economy:jobStarted', source, {
        id = jobId,
        label = job.label,
        routeIndex = 1
    })
end)

RegisterNetEvent('whellco_economy:advanceRoute', function()
    local source = source

    if not canRequest(source) then
        return
    end

    local account = getAccount(source)
    local active = account and activeJobs[account.characterId]

    if not active then
        return
    end

    local job = Config.Jobs[active.id]

    if not job then
        activeJobs[account.characterId] = nil
        return
    end

    local routeIndex = active.routeIndex

    if routeIndex > #job.route then
        return
    end

    local ped = GetPlayerPed(source)
    local waypoint = job.route[routeIndex]

    if #(GetEntityCoords(ped) - waypoint) > 8.0 then
        return
    end

    active.routeIndex = routeIndex + 1

    if active.routeIndex > #job.route then
        TriggerClientEvent('whellco_economy:routeAdvanced', source, {
            routeIndex = active.routeIndex,
            completed = true
        })

        TriggerClientEvent('whellco_economy:notify', source, 'Route complete. Return to the depot to finish.')
    else
        TriggerClientEvent('whellco_economy:routeAdvanced', source, {
            routeIndex = active.routeIndex,
            completed = false
        })
    end
end)

RegisterNetEvent('whellco_economy:completeJob', function()
    local source = source

    if not canRequest(source) then
        return
    end

    local account = getAccount(source)
    local active = account and activeJobs[account.characterId]

    if not active then
        TriggerClientEvent('whellco_economy:notify', source, 'You do not have an active job.')
        return
    end

    local job = Config.Jobs[active.id]

    if not job then
        activeJobs[account.characterId] = nil
        return
    end

    if active.routeIndex <= #job.route then
        TriggerClientEvent('whellco_economy:notify', source, 'Complete the delivery route first.')
        return
    end

    local ped = GetPlayerPed(source)

    if #(GetEntityCoords(ped) - job.complete) > 10.0 then
        TriggerClientEvent('whellco_economy:notify', source, 'Go to the job completion point.')
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
            query = 'UPDATE whellco_players SET bank = ?, xp = ?, level = ? WHERE character_id = ?',
            values = { account.bank, account.xp, account.level, account.characterId }
        },
        {
            query = [[
                INSERT INTO whellco_transactions
                    (character_id, type, amount, balance_after, description)
                VALUES (?, 'wage', ?, ?, ?)
            ]],
            values = {
                account.characterId,
                payout,
                account.bank,
                ('Completed %s job'):format(job.label)
            }
        }
    })

    jobCooldowns[account.characterId] = GetGameTimer()
    activeJobs[account.characterId] = nil

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

RegisterCommand('inventory', function(source)
    if source == 0 then
        return
    end

    TriggerServerEvent('whellco_economy:openInventory')
end, false)

AddEventHandler('playerDropped', function()
    local identifier = getIdentifier(source)

    if identifier and playerAccounts[identifier] then
        local characterId = playerAccounts[identifier].characterId

        if characterId then
            activeJobs[characterId] = nil
        end

        playerAccounts[identifier] = nil
    end

    lastRequest[source] = nil
end)
