local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_staff_panic:alert', function(alert)
    if not alert then
        return
    end

    QBCore.Functions.Notify(
        ('Staff panic: %s'):format(alert.message),
        'error',
        10000
    )

    SetNewWaypoint(alert.coords.x, alert.coords.y)
end)

RegisterCommand('staffpanicinfo', function()
    QBCore.Functions.Notify('Use /staffpanic to alert security if you feel threatened.', 'primary')
end, false)