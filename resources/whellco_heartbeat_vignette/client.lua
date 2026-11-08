local QBCore = exports['qb-core']:GetCoreObject()

local vignetteActive = false

RegisterNetEvent('whellco_heartbeat_vignette:pulse', function()
    SendNUIMessage({ action = 'heartbeat' })
end)

RegisterNetEvent('whellco_heartbeat_vignette:hide', function()
    vignetteActive = false
    SendNUIMessage({ action = 'hide' })
end)

CreateThread(function()
    while true do
        Wait(250)

        local health = GetEntityHealth(PlayerPedId())
        local shouldShow = health > 0 and health <= 30

        if shouldShow and not vignetteActive then
            vignetteActive = true

            CreateThread(function()
                while vignetteActive do
                    TriggerEvent('whellco_heartbeat_vignette:pulse')
                    Wait(900)
                end
            end)
        elseif not shouldShow and vignetteActive then
            TriggerEvent('whellco_heartbeat_vignette:hide')
        end
    end
end)

RegisterCommand('vignetteinfo', function()
    QBCore.Functions.Notify('A red vignette pulses with the heartbeat at low health.', 'primary')
end, false)