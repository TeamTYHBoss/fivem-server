local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_dynamic_radio_static:updateStatic', function(volume)
    local intensity = math.max(0, math.min(1, volume / 0.5))

    SendNUIMessage({
        action = 'setDistortion',
        intensity = intensity
    })
end)

RegisterCommand('toggledistortion', function()
    SendNUIMessage({ action = 'hideDistortion' })
    QBCore.Functions.Notify('Visual distortion disabled.', 'primary')
end, false)

RegisterCommand('distortioninfo', function()
    QBCore.Functions.Notify('Visual distortion intensity follows radio static volume.', 'primary')
end, false)