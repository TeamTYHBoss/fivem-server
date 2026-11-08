local QBCore = exports['qb-core']:GetCoreObject()

local alertCooldowns = {}

local function isNear(coords, detector)
    return #(coords - detector.location) <= detector.radius
end

RegisterNetEvent('whellco_smoke_detector:hazard', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local now = os.time()

    if now - (alertCooldowns[source] or 0) < Config.AlertCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before sending another hazard alert.', 'error')
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    local detector = nil

    for _, d in pairs(Config.SmokeDetectors) do
        if isNear(coords, d) then
            detector = d
            break
        end
    end

    if not detector then
        TriggerClientEvent('QBCore:Notify', source, 'No smoke detector nearby.', 'error')
        return
    end

    alertCooldowns[source] = now

    local alert = {
        source = source,
        name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        detector = detector.label,
        coords = detector.location,
        message = Config.HazardMessage,
        timestamp = os.time()
    }

    local players = QBCore.Functions.GetQBPlayers()

    for _, target in pairs(players) do
        if target.PlayerData.job.name == Config.ManagerJob or target.PlayerData.job.name == Config.SecurityJob then
            TriggerClientEvent('whellco_smoke_detector:alert', target.PlayerData.source, alert)
        end
    end

    TriggerClientEvent('QBCore:Notify', source, 'Hazard alert sent to management and security.', 'success')
end)

RegisterCommand('smokehazard', function(source)
    TriggerEvent('whellco_smoke_detector:hazard')
end, false)