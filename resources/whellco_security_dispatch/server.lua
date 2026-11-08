local QBCore = exports['qb-core']:GetCoreObject()

local dispatchCooldowns = {}

local function isNear(coords, club)
    return #(coords - club.location) <= club.radius
end

RegisterNetEvent('whellco_security_dispatch:panic', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local now = os.time()

    if now - (dispatchCooldowns[source] or 0) < Config.DispatchCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before sending another alert.', 'error')
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if not isNear(coords, Config.StripClub) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not near the club.', 'error')
        return
    end

    dispatchCooldowns[source] = now

    local alert = {
        source = source,
        name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        coords = coords,
        message = Config.DispatchMessage,
        timestamp = os.time()
    }

    local players = QBCore.Functions.GetQBPlayers()

    for _, target in pairs(players) do
        if target.PlayerData.job.name == Config.SecurityJob then
            TriggerClientEvent('whellco_security_dispatch:alert', target.PlayerData.source, alert)
        end
    end

    TriggerClientEvent('QBCore:Notify', source, 'Security has been alerted.', 'success')
end)

RegisterCommand('panic', function(source)
    TriggerEvent('whellco_security_dispatch:panic')
end, false)