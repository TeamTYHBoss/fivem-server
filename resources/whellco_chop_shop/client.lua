local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_chop_shop:chopped', function(data)
    if not data then
        return
    end

    QBCore.Functions.Notify(
        ('Chopped %s for %s%d. Parts: %s.'):format(
            data.plate,
            Config.CurrencySymbol,
            data.total,
            table.concat(data.parts, ', ')
        ),
        'success'
    )
end)

RegisterCommand('chopinfo', function()
    QBCore.Functions.Notify(
        'Use /chopvehicle [stolen] [part1] [part2] at the chop shop. Valid parts: engine, transmission, brakes, suspension, turbo, armor, body.',
        'primary'
    )
end, false)