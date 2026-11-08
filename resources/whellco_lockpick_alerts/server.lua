local QBCore = exports['qb-core']:GetCoreObject()

local alertCooldowns = {}

local function isPolice(Player)
    local job = Player.PlayerData.job

    return job and job.name == Config.PoliceJob
end

local function getPoliceInRadius(coords, radius)
    local players = QBCore.Functions.GetQBCorePlayers()
    local police = {}

    for _, Player in pairs(players) do
        if isPolice(Player) then
            local playerPed = GetPlayerPed(Player.PlayerData.source)
            local playerCoords = GetEntityCoords(playerPed)

            if #(playerCoords - coords) <= radius then
                police[#police + 1] = Player.PlayerData.source
            end
        end
    end

    return police
end

RegisterNetEvent('whellco_lockpick_alerts:failed', function(coords, lockpickType)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local now = os.time()

    if now - (alertCooldowns[source] or 0) < Config.AlertCooldownSeconds then
        return
    end

    alertCooldowns[source] = now

    local police = getPoliceInRadius(coords, Config.AlertRadius)

    for _, policeSource in ipairs(police) do
        TriggerClientEvent('whellco_lockpick_alerts:alert', policeSource, {
            suspectSource = source,
            suspectName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
            coords = coords,
            lockpickType = lockpickType or 'lockpick'
        })
    end
end)

RegisterCommand('testfailedlockpick', function()
    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    TriggerEvent('whellco_lockpick_alerts:failed', coords, 'lockpick')
end, false)