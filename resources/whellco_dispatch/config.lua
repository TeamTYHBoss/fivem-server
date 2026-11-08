Config = {}

Config.Debug = false

Config.DispatchJobs = {
    police = {
        label = 'Police',
        color = '#3b82f6',
        sound = 'CHECKPOINT_PERFECT',
        soundSet = 'HUD_MINI_GAME_SOUNDSET',
        priority = 2
    },
    fire = {
        label = 'Fire Department',
        color = '#ef4444',
        sound = 'TIMER_STOP',
        soundSet = 'HUD_MINI_GAME_SOUNDSET',
        priority = 2
    },
    ambulance = {
        label = 'EMS',
        color = '#22c55e',
        sound = 'CHECKPOINT_PERFECT',
        soundSet = 'HUD_MINI_GAME_SOUNDSET',
        priority = 2
    }
}

Config.CallTypes = {
    ['officer_down'] = {
        label = 'Officer Down',
        jobs = { 'police' },
        priority = 3,
        blipSprite = 161,
        blipColor = 1
    },
    ['structure_fire'] = {
        label = 'Structure Fire',
        jobs = { 'fire' },
        priority = 3,
        blipSprite = 436,
        blipColor = 1
    },
    ['medical_emergency'] = {
        label = 'Medical Emergency',
        jobs = { 'ambulance' },
        priority = 3,
        blipSprite = 153,
        blipColor = 1
    },
    ['vehicle_theft'] = {
        label = 'Vehicle Theft',
        jobs = { 'police' },
        priority = 2,
        blipSprite = 225,
        blipColor = 1
    },
    ['robbery'] = {
        label = 'Robbery In Progress',
        jobs = { 'police' },
        priority = 3,
        blipSprite = 161,
        blipColor = 1
    },
    ['traffic_collision'] = {
        label = 'Traffic Collision',
        jobs = { 'police', 'ambulance' },
        priority = 1,
        blipSprite = 380,
        blipColor = 17
    }
}

Config.NotificationDuration = 10000
Config.MaxActiveBlips = 20
Config.BlipLifetimeSeconds = 120
Config.CooldownSeconds = 5

Config.GpsRouting = {
    enabled = true,
    autoRouteHighPriority = true,
    routeTimeoutSeconds = 180,
    waypointColor = 38,
    clearWaypointOnArrival = true,
    arrivalDistance = 25.0
}