local QBCore = exports['qb-core']:GetCoreObject()

local danceCooldowns = {}

local function isNear(coords, club)
    return #(coords - club.location) <= club.radius
end

RegisterNetEvent('whellco_dance_floor:start', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local now = os.time()

    if now - (danceCooldowns[source] or 0) < Config.DanceCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before dancing again.', 'error')
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if not isNear(coords, Config.StripClub) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not near the dance floor.', 'error')
        return
    end

    danceCooldowns[source] = now

    TriggerClientEvent('whellco_dance_floor:start', source, {
        duration = Config.MinigameDuration,
        successThreshold = Config.SuccessThreshold
    })
end)

RegisterNetEvent('whellco_dance_floor:complete', function(score)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    score = tonumber(score) or 0

    local success = score >= Config.SuccessThreshold
    local reward = success and math.random(Config.DanceRewards.minimum, Config.DanceRewards.maximum) or 0

    if reward > 0 then
        Player.Functions.AddMoney('cash', reward, 'dance-floor-reward')
    end

    TriggerClientEvent('whellco_dance_floor:result', source, {
        score = score,
        success = success,
        reward = reward
    })
end)

RegisterCommand('dance', function(source)
    TriggerEvent('whellco_dance_floor:start')
end, false)