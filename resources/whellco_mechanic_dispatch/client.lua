local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_mechanic_dispatch:dispatch', function(data)
    if not data or not data.coords then
        return
    end

    QBCore.Functions.Notify(
        ('Mechanic dispatch: %s needs %s at %s.'):format(
            data.requesterName,
            data.repairLabel,
            tostring(data.coords)
        ),
        'primary',
        10000
    )
end)

RegisterNetEvent('whellco_mechanic_dispatch:repairStarted', function(data)
    if not data then
        return
    end

    QBCore.Functions.Notify(
        ('%s started. Estimated duration: %d second(s).'):format(
            data.label or 'Repair',
            data.duration or 0
        ),
        'primary'
    )
end)

RegisterCommand('mechanicdispatchinfo', function()
    QBCore.Functions.Notify(
        'Use /callmechanic [repair_type] [reason] to request roadside assistance.',
        'primary'
    )
end, false)