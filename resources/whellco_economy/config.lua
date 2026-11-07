Config = {}

Config.Currency = '£'
Config.StartingCash = 500
Config.StartingBank = 2500

Config.LevelThresholds = {
    0, 250, 600, 1100, 1750, 2600, 3700, 5000, 6600, 8500
}

Config.Shops = {
    legion_247 = {
        label = '24/7 Supermarket',
        coords = vector3(24.4, -1345.7, 29.5),
        items = {
            water = {
                label = 'Bottled Water',
                description = 'Stay hydrated.',
                price = 3,
                xp = 1
            },
            sandwich = {
                label = 'Sandwich',
                description = 'A quick meal.',
                price = 6,
                xp = 2
            },
            energy_drink = {
                label = 'Energy Drink',
                description = 'A caffeinated boost.',
                price = 5,
                xp = 2
            },
            first_aid = {
                label = 'First Aid Kit',
                description = 'Basic medical supplies.',
                price = 25,
                xp = 5
            }
        }
    },
    legion_hardware = {
        label = 'Hardware Store',
        coords = vector3(274.8, -1166.9, 29.4),
        items = {
            repair_kit = {
                label = 'Vehicle Repair Kit',
                description = 'Repair light vehicle damage.',
                price = 150,
                xp = 10
            },
            toolbox = {
                label = 'Toolbox',
                description = 'Useful tools for repairs.',
                price = 90,
                xp = 6
            }
        }
    }
}

Config.Jobs = {
    taxi = {
        label = 'Taxi Driver',
        start = vector3(895.0, -179.0, 74.0),
        complete = vector3(-1285.0, -323.0, 39.0),
        payout = 120,
        xp = 15,
        cooldown = 120000
    },
    delivery = {
        label = 'Delivery Driver',
        start = vector3(-55.0, -1820.0, 27.0),
        complete = vector3(1130.0, -1480.0, 34.0),
        payout = 150,
        xp = 20,
        cooldown = 150000
    },
    mechanic = {
        label = 'Mechanic',
        start = vector3(-337.0, -136.0, 39.0),
        complete = vector3(480.0, -1310.0, 29.0),
        payout = 180,
        xp = 25,
        cooldown = 180000
    },
    garbage = {
        label = 'Garbage Collector',
        start = vector3(-322.0, -1545.0, 31.0),
        complete = vector3(-1050.0, -2700.0, 13.0),
        payout = 100,
        xp = 12,
        cooldown = 90000
    }
}
