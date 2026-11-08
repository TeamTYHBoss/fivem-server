local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_tow_dispatch:dispatch', function(data)
    if not data or not data.coords then
        return
    end

    QBCore.Functions.Notify(
        ('Tow dispatch: %s at %s. Reason: %s.'):format(
            data.requesterName,
            tostring(data.coords),
            data.reason
        ),
        'primary',
        10000
    )
end)

RegisterCommand('towinfo', function()
    QBCore.Functions.Notify(
        ('Tow depot: %s. Use /requesttow [reason] to request recovery.'):format(Config.TowDepot.label),
        'primary'
    )
end, false)