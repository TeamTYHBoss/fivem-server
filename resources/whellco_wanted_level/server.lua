local QBCore = exports['qb-core']:GetCoreObject()

local wantedLevels = {}
local lastKnownPositions = {}

local function getResponse(level)
    return Config.Response[level] or Config.Response[1]
end

RegisterNetEvent('whellco_wanted_level:set', function(level, reason)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    level = math.Clamp(tonumber(level) or 1, 1, Config.Wanted.MaxWantedLevel)

    local current = wantedLevels[source] or 0

    if level <= current then
        return
    end

    wantedLevels[source] = level

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    lastKnownPositions[source] = {
        coords = coords,
        updatedAt = os.time()
    }

    local response = getResponse(level)

    TriggerClientEvent('whellco_wanted_level:update', source, {
        level = level,
        response = response,
        reason = reason
    })

    TriggerClientEvent('whellco_wanted_level:searchArea', -1, {
        coords = coords,
        radius = Config.Wanted.SearchConeRadius,
        expiresAt = os.time() + Config.Wanted.SearchConeDurationSeconds
    })

    for job, enabled in pairs(Config.Wanted.PoliceAlertJobs) do
        if enabled then
            TriggerClientEvent('whellco_wanted_level:policeAlert', -1, job, {
                level = level,
                source = source,
                reason = reason,
                lastKnown = coords
            })
        end
    end

    if level >= 4 then
        for job, enabled in pairs(Config.Wanted.MilitaryAlertJobs) do
            if enabled then
                TriggerClientEvent('whellco_wanted_level:militaryAlert', -1, job, {
                    level = level,
                    source = source,
                    reason = reason,
                    lastKnown = coords
                })
            end
        end
    end
end)

RegisterNetEvent('whellco_wanted_level:positionUpdate', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not wantedLevels[source] then
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    lastKnownPositions[source] = {
        coords = coords,
        updatedAt = os.time()
    }

    TriggerClientEvent('whellco_wanted_level:searchArea', -1, {
        coords = coords,
        radius = Config.Wanted.SearchConeRadius,
        expiresAt = os.time() + Config.Wanted.SearchConeDurationSeconds
    })
end)

RegisterNetEvent('whellco_wanted_level:clear', function()
    local source = source

    wantedLevels[source] = nil
    lastKnownPositions[source] = nil

    TriggerClientEvent('whellco_wanted_level:update', source, {
        level = 0,
        response = getResponse(0),
        reason = 'wanted level cleared'
    })

    TriggerClientEvent('whellco_wanted_level:clearSearch', -1)
end)

CreateThread(function()
    while true do
        Wait(Config.Wanted.LastKnownPositionUpdateSeconds * 1000)

        for source, level in pairs(wantedLevels) do
            if level > 0 then
                TriggerClientEvent('whellco_wanted_level:positionUpdate', source)
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(Config.Wanted.DecayIntervalSeconds * 1000)

        for source, level in pairs(wantedLevels) do
            local newLevel = level - Config.Wanted.DecayPerInterval

            if newLevel <= 0 then
                wantedLevels[source] = nil
                lastKnownPositions[source] = nil

                TriggerClientEvent('whellco_wanted_level:update', source, {
                    level = 0,
                    response = getResponse(0),
                    reason = 'wanted level cleared'
                })

                TriggerClientEvent('whellco_wanted_level:clearSearch', -1)
            else
                wantedLevels[source] = newLevel

                TriggerClientEvent('whellco_wanted_level:update', source, {
                    level = newLevel,
                    response = getResponse(newLevel),
                    reason = 'wanted level decayed'
                })
            end
        end
    end
end)

RegisterCommand('wantedinfo', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    TriggerClientEvent('QBCore:Notify', source, 'Police track last known positions and create search areas.', 'primary')
end, false)