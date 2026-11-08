Config = {}

Config.Debug = false

Config.PoliceJobs = {
    'police'
}

Config.CallTypes = {
    ['officer_down'] = {
        label = 'Officer Down',
        priority = 3,
        blipSprite = 161,
        blipColor = 1,
        sound = 'CHECKPOINT_PERFECT',
        soundSet = 'HUD_MINI_GAME_SOUNDSET'
    },
    ['robbery'] = {
        label = 'Robbery In Progress',
        priority = 3,
        blipSprite = 161,
        blipColor = 1,
        sound = 'CHECKPOINT_PERFECT',
        soundSet = 'HUD_MINI_GAME_SOUNDSET'
    },
    ['vehicle_theft'] = {
        label = 'Vehicle Theft',
        priority = 2,
        blipSprite = 225,
        blipColor = 1,
        sound = 'CHECKPOINT_PERFECT',
        soundSet = 'HUD_MINI_GAME_SOUNDSET'
    },
    ['pursuit'] = {
        label = 'Vehicle Pursuit',
        priority = 3,
        blipSprite = 225,
        blipColor = 1,
        sound = 'CHECKPOINT_PERFECT',
        soundSet = 'HUD_MINI_GAME_SOUNDSET'
    },
    ['shots_fired'] = {
        label = 'Shots Fired',
        priority = 3,
        blipSprite = 161,
        blipColor = 1,
        sound = 'CHECKPOINT_PERFECT',
        soundSet = 'HUD_MINI_GAME_SOUNDSET'
    }
}

Config.NotificationDuration = 10000
Config.CooldownSeconds = 5
Config.RouteTimeoutSeconds = 180
Config.ArrivalDistance = 25.0