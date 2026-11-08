Config = {}

Config.Debug = false

Config.Wanted = {
    DecayIntervalSeconds = 30,
    DecayPerInterval = 1,
    MaxWantedLevel = 5,
    PoliceAlertJobs = {
        police = true
    },
    MilitaryAlertJobs = {
        police = true
    },
    SearchConeRadius = 150.0,
    SearchConeDurationSeconds = 120,
    LastKnownPositionUpdateSeconds = 5
}

-- Minor crimes create a 1 or 2 star response.
-- Serious crimes escalate to 3, 4, or 5 stars.
Config.CrimeLevels = {
    minor = {
        level = 1,
        examples = {'theft', 'trespassing', 'disturbance'}
    },
    moderate = {
        level = 2,
        examples = {'assault', 'vehicle theft', 'resisting arrest'}
    },
    serious = {
        level = 3,
        examples = {'armed robbery', 'kidnapping', 'police pursuit'}
    },
    severe = {
        level = 4,
        examples = {'officer assault', 'hostage situation', 'major pursuit'}
    },
    critical = {
        level = 5,
        examples = {'terror activity', 'mass casualty threat', 'military response'}
    }
}

Config.Response = {
    [1] = {
        policeUnits = 2,
        airSupport = false,
        militaryUnits = 0,
        aggressive = false
    },
    [2] = {
        policeUnits = 4,
        airSupport = false,
        militaryUnits = 0,
        aggressive = false
    },
    [3] = {
        policeUnits = 6,
        airSupport = true,
        militaryUnits = 0,
        aggressive = true
    },
    [4] = {
        policeUnits = 8,
        airSupport = true,
        militaryUnits = 2,
        aggressive = true
    },
    [5] = {
        policeUnits = 12,
        airSupport = true,
        militaryUnits = 4,
        aggressive = true
    }
}