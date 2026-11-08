local QBCore = exports['qb-core']:GetCoreObject()

local activeRobberies = {}
local robberyCooldowns = {}

local function isAdmin(Player)
    local job = Player.PlayerData.job

    return job and Config.AdminJobs[job.name]
end

local function isProtected(Player)
    local job = Player.PlayerData.job

    return job and Config.ProtectedJobs[job.name]
end

local function canStartRobbery(source, targetServerId)
    local now = os.time()
    local key = source .. ':' .. targetServerId

    if now - (robberyCooldowns[key] or 0) < Config.Robbery.CooldownSeconds then
        return false
    end

    robberyCooldowns[key] = now

    return true
end

RegisterNetEvent('whellco_player_robbery:start', function(targetServerId)
    local source = source
    local robber = QBCore.Functions.GetPlayer(source)
    local victim = QBCore.Functions.GetPlayer(targetServerId)

    if not robber or not victim then
        return
    end

    if activeRobberies[source] or activeRobberies[targetServerId] then
        TriggerClientEvent('QBCore:Notify', source, 'A robbery is already in progress.', 'error')
        return
    end

    if isProtected(victim) then
        TriggerClientEvent('QBCore:Notify', source, 'You cannot rob this player.', 'error')
        return
    end

    if not canStartRobbery(source, targetServerId) then
        TriggerClientEvent('QBCore:Notify', source, 'You must wait before robbing this player again.', 'error')
        return
    end

    activeRobberies[source] = targetServerId
    activeRobberies[targetServerId] = source

    TriggerClientEvent('whellco_player_robbery:start', source, targetServerId)
    TriggerClientEvent('whellco_player_robbery:victim', targetServerId, source)
end)

RegisterNetEvent('whellco_player_robbery:complete', function(success)
    local source = source
    local robber = QBCore.Functions.GetPlayer(source)
    local targetServerId = activeRobberies[source]

    if not robber or not targetServerId then
        return
    end

    local victim = QBCore.Functions.GetPlayer(targetServerId)

    if not victim then
        activeRobberies[source] = nil
        return
    end

    activeRobberies[source] = nil
    activeRobberies[targetServerId] = nil

    if not success then
        TriggerClientEvent('QBCore:Notify', source, 'Robbery failed.', 'error')
        TriggerClientEvent('QBCore:Notify', targetServerId, 'You resisted the robbery.', 'success')
        return
    end

    local cash = math.random(Config.Robbery.MinCashPerRobbery, Config.Robbery.MaxCashPerRobbery)
    local itemCount = math.random(0, Config.Robbery.MaxItemsPerRobbery)
    local stolenItems = {}

    for _ = 1, itemCount do
        local item = Config.RobberyItems[math.random(#Config.RobberyItems)]

        if victim.Functions.RemoveItem(item, 1) then
            stolenItems[#stolenItems + 1] = item
        end
    end

    if cash > 0 then
        robber.Functions.AddMoney('cash', cash, 'player-robbery')
        victim.Functions.RemoveMoney('cash', cash, 'player-robbery')
    end

    TriggerClientEvent('QBCore:Notify', source, ('Robbery successful: $%d cash.'):format(cash), 'success')
    TriggerClientEvent('QBCore:Notify', targetServerId, ('You were robbed of $%d cash.'):format(cash), 'error')

    MySQL.query.await(
        [[INSERT INTO whellco_robbery_logs
            (robber_citizenid, victim_citizenid, cash_stolen, items_stolen, success)
          VALUES (?, ?, ?, ?, ?)]],
        {
            robber.PlayerData.citizenid,
            victim.PlayerData.citizenid,
            cash,
            json.encode(stolenItems),
            success and 1 or 0
        }
    )

    if Config.Robbery.AlertPolice and math.random(100) <= Config.Robbery.AlertPoliceChance then
        TriggerClientEvent('whellco_player_robbery:policeAlert', -1, GetEntityCoords(GetPlayerPed(source)))
    end
end)

RegisterCommand('robberyinfo', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isAdmin(Player) then
        return
    end

    TriggerClientEvent('QBCore:Notify', source, 'Walk up to another player and press E to start a robbery.', 'primary')
end, false)