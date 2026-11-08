Config = {}

Config.Debug = false

Config.CurrencySymbol = '$'
Config.InteractionDistance = 5.0
Config.PurchaseCooldownSeconds = 10
Config.TaxPercent = 10
Config.VehiclePlatePrefix = 'WHL'

Config.Dealerships = {
    ['pdm'] = {
        label = 'Premium Deluxe Motorsport',
        location = vector3(-56.8, -1096.6, 26.4),
        spawn = vector4(-30.4, -1080.8, 26.6, 71.5),
        categories = { 'cars', 'sports', 'luxury' }
    },
    ['bennys'] = {
        label = 'Benny’s Motorworks',
        location = vector3(-205.7, -1312.3, 31.3),
        spawn = vector4(-197.0, -1305.0, 31.3, 230.0),
        categories = { 'cars', 'muscle' }
    }
}

Config.Vehicles = {
    ['adder'] = {
        label = 'Adder',
        model = 'adder',
        price = 1000000,
        category = 'sports',
        dealership = 'pdm'
    },
    ['zentorno'] = {
        label = 'Zentorno',
        model = 'zentorno',
        price = 725000,
        category = 'sports',
        dealership = 'pdm'
    },
    ['dominator'] = {
        label = 'Dominator',
        model = 'dominator',
        price = 45000,
        category = 'muscle',
        dealership = 'bennys'
    },
    ['sultan'] = {
        label = 'Sultan',
        model = 'sultan',
        price = 35000,
        category = 'cars',
        dealership = 'bennys'
    }
}