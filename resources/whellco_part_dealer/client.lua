local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_part_dealer:sold', function(data)
    if not data then
        return
    end

    QBCore.Functions.Notify(
        ('Sold %dx %s for %s%d.'):format(
            data.amount,
            data.partType,
            Config.CurrencySymbol,
            data.total
        ),
        'success'
    )
end)

RegisterCommand('partdealerinfo', function()
    local parts = {}

    for partType, price in pairs(Config.PartPrices) do
        parts[#parts + 1] = ('%s - $%d'):format(partType, price)
    end

    QBCore.Functions.Notify(table.concat(parts, ', '), 'primary')
end, false)