local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_impound_lot:release', function(data)
    if not data or not data.plate or not data.spawn then
        return
    end

    QBCore.Functions.Notify(
        ('Vehicle %s released. Collect it at the impound lot.'):format(data.plate),
        'success'
    )
end)

RegisterCommand('impoundinfo', function()
    QBCore.Functions.Notify(
        ('Impound fee: %s%d. Minimum unpaid points: %d.'):format(
            Config.CurrencySymbol,
            Config.ImpoundFee,
            Config.MinUnpaidPoints
        ),
        'primary'
    )
end, false)