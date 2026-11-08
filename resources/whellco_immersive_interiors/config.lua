Config = {}

Config.InteractionDistance = 2.0
Config.LoadDistance = 150.0
Config.UnloadDistance = 200.0

Config.Interiors = {
    ['police_station'] = {
        label = 'Mission Row Police Station',
        interior = 'whellco_police_station',
        entry = vector3(425.1, -979.5, 30.7),
        exit = vector3(441.8, -982.0, 30.7),
        requiredJob = 'police',
        jobGrade = 0,
        rooms = {
            'briefing_room',
            'evidence_room',
            'armory',
            'cells'
        }
    },
    ['mansion'] = {
        label = 'WhellCo Mansion',
        interior = 'whellco_mansion',
        entry = vector3(-1279.7, 292.5, 65.9),
        exit = vector3(-1274.8, 296.8, 65.9),
        requiredJob = nil,
        jobGrade = 0,
        rooms = {
            'living_room',
            'garage',
            'vault',
            'hidden_room'
        }
    },
    ['hidden_room'] = {
        label = 'Hidden Stash Room',
        interior = 'whellco_hidden_room',
        entry = vector3(1273.9, -1710.4, 54.8),
        exit = vector3(1276.4, -1712.1, 54.8),
        requiredJob = nil,
        jobGrade = 0,
        rooms = {
            'stash_room'
        }
    }
}

Config.Interactions = {
    ['police_station'] = {
        {
            id = 'armory',
            label = 'Open Armory',
            coords = vector3(451.7, -980.1, 30.7),
            requiredJob = 'police',
            jobGrade = 2
        },
        {
            id = 'evidence',
            label = 'Access Evidence Storage',
            coords = vector3(470.4, -992.3, 30.7),
            requiredJob = 'police',
            jobGrade = 3
        }
    },
    ['mansion'] = {
        {
            id = 'vault',
            label = 'Open Mansion Vault',
            coords = vector3(-1276.2, 295.1, 65.9),
            requiredJob = nil,
            jobGrade = 0
        }
    }
}