Config = {}

Config.Debug = false

Config.CurrencySymbol = '$'
Config.MaxSaleAmount = 10
Config.SaleCooldownSeconds = 10
Config.CraftCooldownSeconds = 15

Config.CraftingRecipes = {
    packaged_weed = {
        label = 'Packaged Cannabis',
        output = 'packaged_weed',
        outputAmount = 2,
        ingredients = {
            { item = 'weed_bud', amount = 3 },
            { item = 'plastic_bag', amount = 2 }
        },
        requiredJob = nil
    },
    packaged_cocaine = {
        label = 'Packaged Cocaine',
        output = 'packaged_cocaine',
        outputAmount = 2,
        ingredients = {
            { item = 'cocaine', amount = 3 },
            { item = 'plastic_bag', amount = 2 }
        },
        requiredJob = nil
    },
    packaged_meth = {
        label = 'Packaged Methamphetamine',
        output = 'packaged_meth',
        outputAmount = 2,
        ingredients = {
            { item = 'meth', amount = 3 },
            { item = 'plastic_bag', amount = 2 }
        },
        requiredJob = nil
    }
}

Config.SellPrices = {
    packaged_weed = { min = 150, max = 250 },
    packaged_cocaine = { min = 350, max = 550 },
    packaged_meth = { min = 450, max = 700 }
}

Config.SellZones = {
    vector3(-1172.0, -1568.0, 4.6),
    vector3(129.0, -1930.0, 21.0),
    vector3(-616.0, -1613.0, 27.0)
}

Config.CraftingLocations = {
    vector3(-1172.0, -1568.0, 4.6),
    vector3(963.0, -1873.0, 31.0)
}