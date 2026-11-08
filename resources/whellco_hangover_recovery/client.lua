local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_hangover_recovery:recovered', function(data)
    if not data then
        return
    end

    QBCore.Functions.Notify(
        ('Hangover recovery complete. Intoxication: %s%%.'):format(data.intoxication),
        'success'
    )
end)

RegisterCommand('recoverinfo', function()
    QBCore.Functions.Notify('Use /recover [item_name] to recover from a hangover.', 'primary')
end, false)