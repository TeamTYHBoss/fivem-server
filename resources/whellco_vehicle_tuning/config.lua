Config = {}

Config.Debug = false

Config.CurrencySymbol = '$'
Config.InteractionDistance = 5.0
Config.SaveCooldownSeconds = 5

Config.TuningShops = {
    ['ls_customs'] = {
        label = 'LS Customs',
        location = vector3(-337.2, -136.9, 39.0),
        radius = 15.0
    },
    ['bennys'] = {
        label = 'Benny’s Motorworks',
        location = vector3(-205.7, -1312.3, 31.3),
        radius = 15.0
    }
}

Config.Mods = {
    engine = {
        label = 'Engine',
        maxLevel = 5,
        pricePerLevel = 7500
    },
    brakes = {
        label = 'Brakes',
        maxLevel = 3,
        pricePerLevel = 3500
    },
    transmission = {
        label = 'Transmission',
        maxLevel = 4,
        pricePerLevel = 5000
    },
    turbo = {
        label = 'Turbo',
        maxLevel = 1,
        pricePerLevel = 25000
    },
    suspension = {
        label = 'Suspension',
        maxLevel = 4,
        pricePerLevel = 4000
    },
    armor = {
        label = 'Armor',
        maxLevel = 5,
        pricePerLevel = 6000
    }
}

Config.Colors = {
    primary = {
        label = 'Primary Color',
        price = 2500
    },
    secondary = {
        label = 'Secondary Color',
        price = 2000
    }
}