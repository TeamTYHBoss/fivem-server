local QBCore = exports['qb-core']:GetCoreObject()

local activeBlips = {}
local activeRoutes = {}

local function createBlip(call, callConfig)
    if not call.coords then
        return
    end

    local blip = AddBlipForCoord(call.coords.x, call.coords.y, call.coords.z)

    SetBlipSprite(blip, callConfig.blipSprite or 1)
    SetBlipColour(blip, callConfig.blipColor or 1)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(call.label)
    EndTextCommandSetBlipName(blip)

    activeBlips[call.id] = blip

    SetTimeout(callConfig.duration or Config.NotificationDuration, function()
        if activeBlips[call.id] then
            RemoveBlip(activeBlips[call.id])
            activeBlips[call.id] = nil
        end
    end)
end

local function startRoute(call)
    if not Config.GpsRouting.enabled or not call.coords then
        return
    end

    SetNewWaypoint(call.coords.x, call.coords.y)

    activeRoutes[call.id] = {
        coords = call.coords,
        startedAt = GetGameTimer(),
        timeoutMs = (Config.GpsRouting.routeTimeoutSeconds or 180) * 1000
    }
end

local function clearRoute(callId)
    if activeRoutes[callId] then
        DeleteWaypoint()
        activeRoutes[callId] = nil
    end
end

RegisterNetEvent('whellco_dispatch:receiveCall', function(call, settings)
    if not call then
        return
    end

    local job = settings.job or {}

    QBCore.Functions.Notify(
        ('[%s] %s\n%s'):format(job.label or 'Dispatch', call.label, call.details or ''),
        'primary',
        settings.duration or Config.NotificationDuration
    )

    playSoundFrontend(-1, job.sound or 'CHECKPOINT_PERFECT', job.soundSet or 'HUD_MINI_GAME_SOUNDSET', true)
    createBlip(call, settings)

    local shouldRoute = Config.GpsRouting.autoRouteHighPriority and (call.priority or 0) >= 3

    if shouldRoute then
        startRoute(call)
    end
end)

RegisterNetEvent('whellco_dispatch:setRoute', function(callId)
    local call = activeRoutes[callId]

    if not call then
        QBCore.Functions.Notify('No active GPS route for that call.', 'error')
        return
    end

    SetNewWaypoint(call.coords.x, call.coords.y)
    QBCore.Functions.Notify('GPS route set.', 'success')
end)

RegisterNetEvent('whellco_dispatch:clearCall', function(callId)
    if activeBlips[callId] then
        RemoveBlip(activeBlips[callId])
        activeBlips[callId] = nil
    end

    clearRoute(callId)
end)

RegisterCommand('dispatchroute', function(_, args)
    local callId = tonumber(args[1])

    if not callId then
        QBCore.Functions.Notify('Usage: /dispatchroute [call_id]', 'error')
        return
    end

    TriggerServerEvent('whellco_dispatch:requestRoute', callId)
end, false)

RegisterCommand('dispatchclearroute', function()
    for callId in pairs(activeRoutes) do
        clearRoute(callId)
    end

    QBCore.Functions.Notify('All dispatch GPS routes cleared.', 'success')
end, false)

CreateThread(function()
    while true do
        local sleep = 1000

        if next(activeRoutes) then
            sleep = 1000
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local now = GetGameTimer()

            for callId, route in pairs(activeRoutes) do
                if now - route.startedAt > route.timeoutMs then
                    clearRoute(callId)
                elseif Config.GpsRouting.clearWaypointOnArrival then
                    local distance = #(coords - route.coords)

                    if distance <= (Config.GpsRouting.arrivalDistance or 25.0) then
                        clearRoute(callId)
                        QBCore.Functions.Notify('Arrived at dispatch location.', 'success')
                    end
                end
            end
        end

        Wait(sleep)
    end
end)