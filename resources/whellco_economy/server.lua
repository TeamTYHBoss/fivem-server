local QBCore = exports['qb-core']:GetCoreObject()

local activeJobs = {}
local jobCooldowns = {}
local lastRequest = {}

local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
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

local function getCharacterId(Player)
    local row = MySQL.single.await(
        [[
            SELECT character_id
            FROM whellco_players
            WHERE identifier = ?
            ORDER BY created_at DESC
            LIMIT 1
        ]],
        { Player.PlayerData.identifier }
    )

    if row then
        return row.character_id
    end

    return MySQL.insert.await(
        [[
            INSERT INTO whellco_players
                (identifier, player_name, cash, bank, xp, level)
            VALUES (?, ?, 0, 0, 0, 1)
        ]],
        { Player.PlayerData.identifier, Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname }
    )
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

local function sendAccount(source)
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    local characterId = getCharacterId(Player)
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

    TriggerClientEvent('whellco_economy:updateAccount', source, {
        cash = Player.Functions.GetMoney('cash'),
        bank = Player.Functions.GetMoney('bank'),
        xp = Player.PlayerData.metadata.whellco_xp or 0,
        level = Player.PlayerData.metadata.whellco_level or 1,
        transactions = transactions
    })
end

local function sendInventory(source)
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    local characterId = getCharacterId(Player)
    local items = getInventoryItems(characterId)
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
    local Player = getQbPlayer(source)

    if not Player or not characterId then
        return
    end

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
    local Player = getQbPlayer(source)

    if not shop or not Player then
        return
    end

    local ped = GetPlayerPed(source)

    if #(GetEntityCoords(ped) - shop.coords) > 5.0 then
        return
    end

    SetNuiFocus(source, true, true)

    TriggerClientEvent('whellco_economy:openShop', source, {
        shopId = shopId,
        label = shop.label,
        items = shop.items,
        cash = Player.Functions.GetMoney('cash'),
        bank = Player.Functions.GetMoney('bank')
    })
end)

RegisterNuiCallback('closeShop', function(_, cb)
    local source = source

    SetNuiFocus(source, false, false)
    cb({ ok = true })
end)

RegisterNuiCallback('purchaseItem', function(data, cb)
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        cb({ ok = false, error = 'You must be logged in.' })
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

    if Player.Functions.GetMoney('cash') < total then
        cb({ ok = false, error = 'You do not have enough cash.' })
        return
    end

    if not Player.Functions.RemoveMoney('cash', total, ('Purchased %s'):format(item.label)) then
        cb({ ok = false, error = 'Purchase failed.' })
        return
    end

    local characterId = getCharacterId(Player)

    MySQL.query.await(
        [[
            INSERT INTO whellco_inventory (character_id, item_id, quantity)
            VALUES (?, ?, ?)
            ON DUPLICATE KEY UPDATE quantity = quantity + VALUES(quantity)
        ]],
        { characterId, data.itemId, quantity }
    )

    MySQL.insert.await(
        [[
            INSERT INTO whellco_transactions
                (character_id, type, amount, balance_after, description)
            VALUES (?, 'purchase', ?, ?, ?)
        ]],
        {
            characterId,
            total,
            Player.Functions.GetMoney('cash'),
            ('Purchased %dx %s'):format(quantity, item.label)
        }
    )

    local xp = (Player.PlayerData.metadata.whellco_xp or 0) + (item.xp * quantity)
    local level = getLevel(xp)

    Player.Functions.SetMetaData('whellco_xp', xp)
    Player.Functions.SetMetaData('whellco_level', level)

    if level > (Player.PlayerData.metadata.whellco_level or 1) then
        TriggerClientEvent('whellco_economy:levelUp', source, level)
    end

    sendAccount(source)

    cb({
        ok = true,
        receipt = {
            item = item.label,
            quantity = quantity,
            total = total,
            cash = Player.Functions.GetMoney('cash'),
            xp = xp,
            level = level
        }
    })
end)

RegisterNuiCallback('useItem', function(data, cb)
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        cb({ ok = false, error = 'You must be logged in.' })
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

    local characterId = getCharacterId(Player)

    local updated = MySQL.update.await(
        [[
            UPDATE whellco_inventory
            SET quantity = quantity - 1
            WHERE character_id = ? AND item_id = ? AND quantity > 0
        ]],
        { characterId, itemId }
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

    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    local characterId = getCharacterId(Player)
    local jobs = {}

    for id, job in pairs(Config.Jobs) do
        local remaining = math.max(0, job.cooldown - (GetGameTimer() - (jobCooldowns[characterId] or 0)))

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
    local Player = getQbPlayer(source)

    if not job or not Player then
        return
    end

    local characterId = getCharacterId(Player)

    if activeJobs[characterId] then
        TriggerClientEvent('QBCore:Notify', source, 'You are already on a job.', 'error')
        return
    end

    local now = GetGameTimer()

    if now - (jobCooldowns[characterId] or 0) < job.cooldown then
        TriggerClientEvent('QBCore:Notify', source, 'You need to wait before starting this job again.', 'error')
        return
    end

    local ped = GetPlayerPed(source)

    if #(GetEntityCoords(ped) - job.start) > 10.0 then
        TriggerClientEvent('QBCore:Notify', source, 'You are too far from the job start location.', 'error')
        return
    end

    activeJobs[characterId] = {
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

    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    local characterId = getCharacterId(Player)
    local active = activeJobs[characterId]

    if not active then
        return
    end

    local job = Config.Jobs[active.id]

    if not job then
        activeJobs[characterId] = nil
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

        TriggerClientEvent('QBCore:Notify', source, 'Route complete. Return to the depot to finish.', 'primary')
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

    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    local characterId = getCharacterId(Player)
    local active = activeJobs[characterId]

    if not active then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have an active job.', 'error')
        return
    end

    local job = Config.Jobs[active.id]

    if not job then
        activeJobs[characterId] = nil
        return
    end

    if active.routeIndex <= #job.route then
        TriggerClientEvent('QBCore:Notify', source, 'Complete the delivery route first.', 'error')
        return
    end

    local ped = GetPlayerPed(source)

    if #(GetEntityCoords(ped) - job.complete) > 10.0 then
        TriggerClientEvent('QBCore:Notify', source, 'Go to the job completion point.', 'error')
        return
    end

    local payout = job.payout
    local xpGain = job.xp

    if not Player.Functions.AddMoney('bank', payout, ('Completed %s job'):format(job.label)) then
        return
    end

    local xp = (Player.PlayerData.metadata.whellco_xp or 0) + xpGain
    local level = getLevel(xp)

    Player.Functions.SetMetaData('whellco_xp', xp)
    Player.Functions.SetMetaData('whellco_level', level)

    MySQL.insert.await(
        [[
            INSERT INTO whellco_transactions
                (character_id, type, amount, balance_after, description)
            VALUES (?, 'wage', ?, ?, ?)
        ]],
        {
            characterId,
            payout,
            Player.Functions.GetMoney('bank'),
            ('Completed %s job'):format(job.label)
        }
    )

    jobCooldowns[characterId] = GetGameTimer()
    activeJobs[characterId] = nil

    if level > (Player.PlayerData.metadata.whellco_level or 1) then
        TriggerClientEvent('whellco_economy:levelUp', source, level)
    end

    sendAccount(source)

    TriggerClientEvent('QBCore:Notify', source, ('Job complete! %s%d added to bank.'):format(Config.Currency, payout), 'success')
    TriggerClientEvent('whellco_economy:jobCompleted', source)
end)

RegisterCommand('cash', function(source)
    if source == 0 then
        return
    end

    local Player = getQbPlayer(source)

    if Player then
        TriggerClientEvent('QBCore:Notify', source, ('Cash: %s%d | Bank: %s%d'):format(
            Config.Currency,
            Player.Functions.GetMoney('cash'),
            Config.Currency,
            Player.Functions.GetMoney('bank')
        ), 'primary')
    end
end, false)

RegisterCommand('bank', function(source)
    if source == 0 then
        return
    end

    local Player = getQbPlayer(source)

    if Player then
        TriggerClientEvent('QBCore:Notify', source, ('Bank balance: %s%d'):format(
            Config.Currency,
            Player.Functions.GetMoney('bank')
        ), 'primary')
    end
end, false)

RegisterCommand('inventory', function(source)
    if source == 0 then
        return
    end

    TriggerServerEvent('whellco_economy:openInventory')
end, false)

AddEventHandler('playerDropped', function()
    local Player = getQbPlayer(source)

    if Player then
        local characterId = getCharacterId(Player)

        activeJobs[characterId] = nil
    end

    lastRequest[source] = nil
end)