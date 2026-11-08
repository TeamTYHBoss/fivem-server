Config = {}

Config.Debug = false

Config.CurrencySymbol = '$'
Config.MechanicJob = 'mechanic'
Config.DispatchCooldownSeconds = 30
Config.RepairCooldownSeconds = 15
Config.RepairFee = 1500

Config.MechanicShop = {
    label = 'Wheller Auto Repair',
    location = vector3(-355.6, -135.4, 39.0),
    radius = 15.0
}

Config.RepairVehicle = 'flatbed'

Config.RepairTypes = {
    engine = {
        label = 'Engine Repair',
        price = 1500,
        duration = 30
    },
    body = {
        label = 'Body Repair',
        price = 1000,
        duration = 20
    },
    tyres = {
        label = 'Tyre Repair',
        price = 750,
        duration = 15
    },
    full = {
        label = 'Full Repair',
        price = 3000,
        duration = 60
    }
}