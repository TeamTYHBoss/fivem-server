local QBCore = exports['qb-core']:GetCoreObject()

local activeBlips = {}
local activeRoutes = {}

local function createBlip(call, settings)
    if not call.coords then
        return
    end

    local blip = AddBlipForCoord(call.coords.x, call.coords.y, call.coords.z)

    SetBlipSprite(blip, settings.blipSprite or 1)
    SetBlipColour(blip, settings.blipColor or 1)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(call.label)
    EndTextCommandSetBlipName(blip)

    activeBlips[call.id] = blip

    SetTimeout(settings.duration or Config.NotificationDuration, function()
        if activeBlips[call.id] then
            RemoveBlip(activeBlips[call.id])
            activeBlips[call.id] = nil
        end
    end)
end

local function setRoute(call)
    if not call.coords then
        return
    end

    SetNewWaypoint(call.coords.x, call.coords.y)

    activeRoutes[call.id] = {
        coords = call.coords,
        startedAt = GetGameTimer()
    }
end

RegisterNetEvent('whellco_police_dispatch:receiveCall', function(call, settings)
    if not call then
        return
    end

    QBCore.Functions.Notify(
        ('[POLICE] %s\n%s'):format(call.label, call.details or ''),
        'primary',
        settings.duration or Config.NotificationDuration
    )

    playSoundFrontend(-1, settings.sound or 'CHECKPOINT_PERFECT', settings.soundSet or 'HUD_MINI_GAME_SOUNDSET', true)
    createBlip(call, settings)

    if call.priority >= 3 then
        setRoute(call)
    end
end)

RegisterNetEvent('whellco_police_dispatch:setRoute', function(callId)
    local call = activeRoutes[callId]

    if not call then
        QBCore.Functions.Notify('No active route for that call.', 'error')
        return
    end

    SetNewWaypoint(call.coords.x, call.coords.y)
    QBCore.Functions.Notify('Police dispatch route set.', 'success')
end)

RegisterNetEvent('whellco_police_dispatch:clearCall', function(callId)
    if activeBlips[callId] then
        RemoveBlip(activeBlips[callId])
        activeBlips[callId] = nil
    end

    if activeRoutes[callId] then
        DeleteWaypoint()
        activeRoutes[callId] = nil
    end
end)

RegisterCommand('policedispatch', function(_, args)
    local callType = args[1]
    local details = table.concat(args, ' ', 2)

    if not callType then
        QBCore.Functions.Notify('Usage: /policedispatch [call_type] [details]', 'error')
        return
    end

    TriggerServerEvent('whellco_police_dispatch:sendCall', callType, details)
end, false)

RegisterCommand('policedispatchroute', function(_, args)
    local callId = tonumber(args[1])

    if not callId then
        QBCore.Functions.Notify('Usage: /policedispatchroute [call_id]', 'error')
        return
    end

    TriggerServerEvent('whellco_police_dispatch:requestRoute', callId)
end, false)

RegisterCommand('policedispatchclear', function(_, args)
    local callId = tonumber(args[1])

    if not callId then
        QBCore.Functions.Notify('Usage: /policedispatchclear [call_id]', 'error')
        return
    end

    TriggerServerEvent('whellco_police_dispatch:clearCall', callId)
end, false)

CreateThread(function()
    while true do
        local sleep = 1000

        if next(activeRoutes) then
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)

            for callId, route in pairs(activeRoutes) do
                if #(coords - route.coords) <= Config.ArrivalDistance then
                    DeleteWaypoint()
                    activeRoutes[callId] = nil
                    QBCore.Functions.Notify('Arrived at police dispatch location.', 'success')
                end
            end
        end

        Wait(sleep)
    end
end)