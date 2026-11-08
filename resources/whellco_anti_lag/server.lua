local QBCore = exports['qb-core']:GetCoreObject()

local lagScores = {}
local rateBuckets = {}

local function isAdmin(Player)
    local job = Player.PlayerData.job

    return job and Config.AdminJobs[job.name]
end

local function addLagScore(source, amount, reason)
    lagScores[source] = (lagScores[source] or 0) + amount

    MySQL.query.await(
        [[INSERT INTO whellco_anti_lag_events
            (player_citizenid, event_type, score, details)
          VALUES (?, ?, ?, ?)]],
        {
            Player and Player.PlayerData.citizenid or 'unknown',
            reason,
            amount,
            json.encode({source = source, score = lagScores[source]})
        }
    )

    local score = lagScores[source]

    if Config.Enforcement.AutomaticKick and score >= Config.Enforcement.KickThreshold then
        DropPlayer(source, 'Anti-lag: excessive resource usage detected.')
    elseif score >= Config.Enforcement.WarnThreshold then
        TriggerClientEvent('QBCore:Notify', source, 'Anti-lag warning: reduce excessive activity.', 'error')
    end
end

local function isRateLimited(source, key, limit)
    local now = os.time()
    local window = math.floor(now / 60)
    local bucket = key .. ':' .. source .. ':' .. window

    rateBuckets[bucket] = (rateBuckets[bucket] or 0) + 1

    return rateBuckets[bucket] > limit
end

RegisterNetEvent('whellco_anti_lag:performance', function(data)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local tickRate = tonumber(data.tickRate) or 0

    if tickRate >= Config.Performance.TickRateCriticalMs then
        addLagScore(source, 15, 'critical-client-tick')
    elseif tickRate >= Config.Performance.TickRateWarningMs then
        addLagScore(source, 5, 'high-client-tick')
    end
end)

RegisterNetEvent('whellco_anti_lag:entityReport', function(data)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local peds = tonumber(data.peds) or 0
    local vehicles = tonumber(data.vehicles) or 0
    local objects = tonumber(data.objects) or 0

    if peds > Config.Performance.MaxPedsPerPlayer then
        addLagScore(source, 10, 'excessive-peds')
    end

    if vehicles > Config.Performance.MaxVehiclesPerPlayer then
        addLagScore(source, 10, 'excessive-vehicles')
    end

    if objects > Config.Performance.MaxObjectsPerPlayer then
        addLagScore(source, 10, 'excessive-objects')
    end
end)

RegisterNetEvent('whellco_anti_lag:event', function(eventType)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local limit = Config.RateLimits[eventType .. 'PerMinute']

    if not limit then
        return
    end

    if isRateLimited(source, eventType, limit) then
        addLagScore(source, 15, eventType .. '-rate-limit')
    end
end)

AddEventHandler('playerDropped', function()
    lagScores[source] = nil
end)

RegisterCommand('antistutter', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isAdmin(Player) then
        return
    end

    TriggerClientEvent('QBCore:Notify', source, 'Anti-lag monitoring is active.', 'primary')
end, false)