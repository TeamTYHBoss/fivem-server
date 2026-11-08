local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_smoke_detector:alert', function(alert)
    if not alert then
        return
    end

    QBCore.Functions.Notify(
        ('Smoke hazard: %s'):format(alert.message),
        'error',
        10000
    )

    SetNewWaypoint(alert.coords.x, alert.coords.y)
end)

RegisterCommand('smokehazardinfo', function()
    QBCore.Functions.Notify('Use /smokehazard to report smoke near a detector.', 'primary')
end, false)