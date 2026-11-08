local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
    while true do
        Wait(30000)

        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

        TriggerServerEvent('whellco_staff_idle_duty:activity', {
            coords = coords
        })
    end
end)

RegisterCommand('idledutyinfo', function()
    QBCore.Functions.Notify('Staff are automatically set off duty after inactivity.', 'primary')
end, false)