local QBCore = exports['qb-core']:GetCoreObject()

local activeBlips = {}

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
end)

RegisterNetEvent('whellco_dispatch:clearCall', function(callId)
    if activeBlips[callId] then
        RemoveBlip(activeBlips[callId])
        activeBlips[callId] = nil
    end
end)

RegisterCommand('dispatch', function(_, args)
    local callType = args[1]
    local details = table.concat(args, ' ', 2)

    if not callType then
        QBCore.Functions.Notify('Usage: /dispatch [call_type] [details]', 'error')
        return
    end

    TriggerServerEvent('whellco_dispatch:sendCall', callType, details)
end, false)

RegisterCommand('dispatchclear', function(_, args)
    local callId = tonumber(args[1])

    if not callId then
        QBCore.Functions.Notify('Usage: /dispatchclear [call_id]', 'error')
        return
    end

    TriggerServerEvent('whellco_dispatch:clearCall', callId)
end, false)