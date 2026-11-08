local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand('blackmarketitems', function()
    local items = {}

    for itemName, item in pairs(Config.BlackMarket.items) do
        items[#items + 1] = ('%s - $%d'):format(itemName, item.price)
    end

    QBCore.Functions.Notify(table.concat(items, ', '), 'primary')
end, false)

RegisterCommand('launderinfo', function()
    QBCore.Functions.Notify(
        ('Laundering fee: %d%%. Minimum: $%d. Maximum: $%d.'):format(
            Config.LaunderFeePercent,
            Config.Laundering.minAmount,
            Config.Laundering.maxAmount
        ),
        'primary'
    )
end, false)