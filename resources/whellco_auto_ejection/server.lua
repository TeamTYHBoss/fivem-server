local QBCore = exports['qb-core']:GetCoreObject()

local ejectionCooldowns = {}

local function isNear(coords, club)
    return #(coords - club.location) <= club.radius
end

RegisterNetEvent('whellco_auto_ejection:check', function(intoxication)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    intoxication = tonumber(intoxication) or 0

    if intoxication < Config.HighIntoxicationThreshold then
        return
    end

    local now = os.time()

    if now - (ejectionCooldowns[source] or 0) < Config.EjectionCooldownSeconds then
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if not isNear(coords, Config.StripClub) then
        return
    end

    ejectionCooldowns[source] = now

    TriggerClientEvent('whellco_auto_ejection:ejected', source, {
        reason = 'High intoxication detected',
        intoxication = intoxication,
        ejectLocation = Config.StripClub.ejectLocation
    })

    local players = QBCore.Functions.GetQBPlayers()

    for _, target in pairs(players) do
        if target.PlayerData.job.name == Config.SecurityJob then
            TriggerClientEvent('whellco_auto_ejection:alert', target.PlayerData.source, {
                name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
                intoxication = intoxication,
                coords = coords
            })
        end
    end
end)

RegisterCommand('autoejectinfo', function(source)
    TriggerClientEvent('QBCore:Notify', source, 'Automatic ejection activates at high intoxication.', 'primary')
end, false)