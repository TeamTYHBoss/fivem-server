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
