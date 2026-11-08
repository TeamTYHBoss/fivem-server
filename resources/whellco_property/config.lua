Config = {}

Config.Debug = false

Config.CurrencySymbol = '$'
Config.MaxKeysPerProperty = 5
Config.RentCycleDays = 7

Config.PropertyTypes = {
    apartment = {
        label = 'Apartment',
        price = 75000,
        rent = 2500,
        storage = 50,
        garageSlots = 1
    },
    house = {
        label = 'House',
        price = 250000,
        rent = 7500,
        storage = 100,
        garageSlots = 2
    },
    mansion = {
        label = 'Mansion',
        price = 1250000,
        rent = 25000,
        storage = 200,
        garageSlots = 6
    }
}

Config.Properties = {
    ['apartment_1'] = {
        type = 'apartment',
        label = 'Downtown Apartment 1',
        entrance = vector3(-269.4, -955.3, 31.2),
        exit = vector3(-269.4, -955.3, 31.2),
        interior = vector3(-274.1, -961.2, 31.2),
        garage = vector3(-274.0, -930.0, 31.0)
    },
    ['house_1'] = {
        type = 'house',
        label = 'Vinewood House 1',
        entrance = vector3(-1279.7, 292.5, 65.9),
        exit = vector3(-1274.8, 296.8, 65.9),
        interior = vector3(-1276.2, 295.1, 65.9),
        garage = vector3(-1270.0, 300.0, 66.0)
    }
}