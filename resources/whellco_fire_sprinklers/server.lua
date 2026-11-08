local QBCore = exports['qb-core']:GetCoreObject()

local sprinklerCooldowns = {}
local activeSprinklers = {}

local function isAuthorised(Player)
    local job = Player.PlayerData.job

    return job and (job.name == Config.ManagerJob or job.name == Config.SecurityJob)
end

RegisterNetEvent('whellco_fire_sprinklers:activate', function(zoneIndex)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isAuthorised(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not authorised to activate sprinklers.', 'error')
        return
    end

    local now = os.time()

    if now - (sprinklerCooldowns[source] or 0) < Config.SprinklerCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before activating sprinklers again.', 'error')
        return
    end

    local zone = Config.SprinklerZones[tonumber(zoneIndex) or 0]

    if not zone then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid sprinkler zone selected.', 'error')
        return
    end

    sprinklerCooldowns[source] = now
    activeSprinklers[zoneIndex] = now + Config.SprinklerDuration

    local players = QBCore.Functions.GetQBPlayers()

    for _, target in pairs(players) do
        TriggerClientEvent('whellco_fire_sprinklers:activate', target.PlayerData.source, {
            zone = zone,
            duration = Config.SprinklerDuration
        })
    end

    TriggerClientEvent('QBCore:Notify', source, ('Sprinklers activated in %s.'):format(zone.label), 'success')
end)

RegisterCommand('sprinklers', function(source, args)
    local zoneIndex = args[1]

    if not zoneIndex then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /sprinklers [zone_id]', 'error')
        return
    end

    TriggerEvent('whellco_fire_sprinklers:activate', zoneIndex)
end, false)