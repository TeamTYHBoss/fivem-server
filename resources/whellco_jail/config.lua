Config = {}

Config.Debug = false

Config.PoliceJobs = {
    'police'
}

Config.MaxSentenceMinutes = 120
Config.MinSentenceMinutes = 1
Config.ReleaseDistance = 25.0

Config.Jail = {
    entrance = vector3(442.5, -1017.4, 28.6),
    release = vector3(438.4, -1018.3, 27.7),
    cells = {
        vector3(462.7, -1000.1, 25.7),
        vector3(462.7, -1003.1, 25.7),
        vector3(462.7, -1006.1, 25.7)
    }
}

Config.Prison = {
    entrance = vector3(1677.2, 2517.0, 45.6),
    release = vector3(1677.2, 2517.0, 45.6),
    yard = vector3(1691.0, 2560.0, 45.6),
    workZone = vector3(1700.0, 2560.0, 45.6)
}

Config.JailJobs = {
    { label = 'Clean Cells', reward = 50, xp = 2 },
    { label = 'Sort Mail', reward = 40, xp = 2 },
    { label = 'Laundry Duty', reward = 45, xp = 2 }
}

Config.PrisonJobs = {
    { label = 'Yard Patrol', reward = 60, xp = 3 },
    { label = 'Kitchen Duty', reward = 55, xp = 3 },
    { label = 'Workshop Duty', reward = 70, xp = 4 }
}