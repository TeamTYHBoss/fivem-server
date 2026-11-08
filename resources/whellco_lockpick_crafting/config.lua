Config = {}

Config.Debug = false

Config.CurrencySymbol = '$'
Config.CraftCooldownSeconds = 10
Config.CraftTime = 8

Config.CraftingLocation = {
    label = 'Lockpick Workbench',
    location = vector3(970.0, -1830.0, 31.0),
    radius = 5.0
}

Config.Recipes = {
    lockpick = {
        label = 'Lockpick',
        outputAmount = 1,
        materials = {
            scrapmetal = 2,
            steel = 1
        }
    },
    advanced_lockpick = {
        label = 'Advanced Lockpick',
        outputAmount = 1,
        materials = {
            scrapmetal = 4,
            steel = 2,
            electronics = 1
        }
    }
}