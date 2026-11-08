local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_drink_intoxication_link:consumed', function(data)
    if not data then
        return
    end

    QBCore.Functions.Notify(
        ('Drink quality: %s. Intoxication: %s%%.'):format(data.quality, data.intoxication),
        'primary'
    )
end)

RegisterCommand('drinkqualityinfo', function()
    QBCore.Functions.Notify('Drink quality affects patron intoxication.', 'primary')
end, false)