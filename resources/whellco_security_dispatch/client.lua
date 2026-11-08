local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_security_dispatch:alert', function(alert)
    if not alert then
        return
    end

    QBCore.Functions.Notify(
        ('Security dispatch: %s'):format(alert.message),
        'error',
        10000
    )

    SetNewWaypoint(alert.coords.x, alert.coords.y)
end)

RegisterCommand('dispatchinfo', function()
    QBCore.Functions.Notify('Use /panic to alert security if you feel unsafe.', 'primary')
end, false)