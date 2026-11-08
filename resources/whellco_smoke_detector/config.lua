Config = {}

Config.Debug = false

Config.ManagerJob = 'manager'
Config.SecurityJob = 'security'
Config.AlertCooldownSeconds = 30

Config.StripClub = {
    label = 'Wheller Velvet Lounge',
    location = vector3(127.3, -1299.9, 29.3),
    radius = 30.0
}

Config.SmokeDetectors = {
    {
        label = 'Main Floor Detector',
        location = vector3(127.3, -1299.9, 31.0),
        radius = 10.0
    },
    {
        label = 'Bar Area Detector',
        location = vector3(130.0, -1295.0, 31.0),
        radius = 8.0
    }
}

Config.HazardMessage = 'Smoke detected. Please investigate the hazard immediately.'