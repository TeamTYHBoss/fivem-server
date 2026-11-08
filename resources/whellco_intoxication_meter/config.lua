Config = {}

Config.Debug = false

Config.SecurityJob = 'security'
Config.CheckCooldownSeconds = 10
Config.MaxIntoxication = 100
Config.IntoxicationDecayPerMinute = 5

Config.StripClub = {
    label = 'Wheller Velvet Lounge',
    location = vector3(127.3, -1299.9, 29.3),
    radius = 30.0
}

Config.Levels = {
    {
        label = 'Sober',
        min = 0,
        max = 19
    },
    {
        label = 'Tipsy',
        min = 20,
        max = 49
    },
    {
        label = 'Drunk',
        min = 50,
        max = 79
    },
    {
        label = 'Very Drunk',
        min = 80,
        max = 100
    }
}