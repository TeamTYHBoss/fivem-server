Config = {}

Config.Debug = false

Config.CurrencySymbol = '$'
Config.InteractionDistance = 3.0
Config.RefuelCooldownSeconds = 3
Config.MaxFuelLevel = 100.0

Config.FuelPricePerLitre = 2.25
Config.StartingFuel = 35.0
Config.FuelConsumptionPerSecond = 0.15

Config.GasStations = {
    ['xero_gas'] = {
        label = 'Xero Gas Station',
        location = vector3(49.4, 2778.8, 58.0),
        radius = 15.0
    },
    ['ron_gas'] = {
        label = 'RON Gas Station',
        location = vector3(263.9, 2603.5, 44.9),
        radius = 15.0
    },
    ['ls_customs_gas'] = {
        label = 'LS Customs Gas Station',
        location = vector3(-724.6, -935.1, 19.2),
        radius = 15.0
    }
}