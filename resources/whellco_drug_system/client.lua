local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand('drugrecipes', function()
    local recipes = {}

    for name, recipe in pairs(Config.CraftingRecipes) do
        recipes[#recipes + 1] = ('%s - %s'):format(name, recipe.label)
    end

    QBCore.Functions.Notify(table.concat(recipes, ', '), 'primary')
end, false)

RegisterCommand('drugsellitems', function()
    local items = {}

    for itemName, price in pairs(Config.SellPrices) do
        items[#items + 1] = ('%s ($%d-$%d)'):format(itemName, price.min, price.max)
    end

    QBCore.Functions.Notify(table.concat(items, ', '), 'primary')
end, false)