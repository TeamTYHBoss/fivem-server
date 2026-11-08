local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_auto_ejection:ejected', function(data)
    if not data or not data.ejectLocation then
        return
    end

    local playerPed = PlayerPedId()

    QBCore.Functions.Notify(
        ('Automatic ejection: %s'):format(data.reason or 'High intoxication detected'),
        'error',
        10000
    )

    SetEntityCoords(
        playerPed,
        data.ejectLocation.x,
        data.ejectLocation.y,
        data.ejectLocation.z,
        false,
        false,
        false,
        false
    )

    SetEntityHeading(playerPed, data.ejectLocation.w)
end)

RegisterNetEvent('whellco_auto_ejection:alert', function(alert)
    if not alert then
        return
    end

    QBCore.Functions.Notify(
        ('Automatic ejection: %s at %s%% intoxication.'):format(alert.name, alert.intoxication),
        'error',
        10000
    )

    SetNewWaypoint(alert.coords.x, alert.coords.y)
end)