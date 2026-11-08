Config = {}

Config.Debug = false

Config.AllowedGangs = {
    'ballas',
    'vagos',
    'families'
}

Config.TerritoryCaptureTime = 180
Config.TerritoryCooldownMinutes = 30
Config.MinAttackers = 2
Config.MinDefenders = 1
Config.RewardMoney = 5000
Config.RewardXp = 25

Config.Territories = {
    ['grove_street'] = {
        label = 'Grove Street',
        center = vector3(-1950.0, -1000.0, 10.0),
        radius = 150.0
    },
    ['east_side'] = {
        label = 'East Side',
        center = vector3(1000.0, -1500.0, 10.0),
        radius = 175.0
    },
    ['downtown'] = {
        label = 'Downtown Block',
        center = vector3(150.0, -1000.0, 29.0),
        radius = 125.0
    }
}