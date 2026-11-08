local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_traffic_fines:ticketIssued', function(data)
    if not data then
        return
    end

    QBCore.Functions.Notify(
        ('Traffic ticket issued: %s. Fine: $%d. Points: %d.'):format(
            data.label,
            data.amount,
            data.points
        ),
        'error',
        10000
    )
end)

RegisterCommand('ticketinfo', function()
    QBCore.Functions.Notify(
        'Use /myfines to view fines, /payfine [id] to pay, and /licensepoints to check points.',
        'primary'
    )
end, false)