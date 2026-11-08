Config = {}

Config.Debug = false

Config.CurrencySymbol = '$'
Config.InteractionDistance = 2.0
Config.MaxKeysPerProperty = 5

Config.HousingTypes = {
    apartment = {
        label = 'Apartment',
        price = 75000,
        stashSlots = 40,
        stashWeight = 80000,
        wardrobeSlots = 10
    },
    house = {
        label = 'House',
        price = 250000,
        stashSlots = 80,
        stashWeight = 150000,
        wardrobeSlots = 20
    },
    mansion = {
        label = 'Mansion',
        price = 1250000,
        stashSlots = 150,
        stashWeight = 300000,
        wardrobeSlots = 40
    }
}

Config.Properties = {
    ['apartment_1'] = {
        type = 'apartment',
        label = 'Downtown Apartment 1',
        entrance = vector3(-269.4, -955.3, 31.2),
        exit = vector3(-269.4, -955.3, 31.2),
        stash = vector3(-274.1, -961.2, 31.2),
        wardrobe = vector3(-276.0, -958.0, 31.2)
    },
    ['house_1'] = {
        type = 'house',
        label = 'Vinewood House 1',
        entrance = vector3(-1279.7, 292.5, 65.9),
        exit = vector3(-1274.8, 296.8, 65.9),
        stash = vector3(-1276.2, 295.1, 65.9),
        wardrobe = vector3(-1278.0, 294.0, 65.9)
    }
}