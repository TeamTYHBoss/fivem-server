Config = {}

Config.Debug = false

Config.Disguise = {
    RequiredItem = 'disguise_kit',
    EntryDurationSeconds = 120,
    CooldownSeconds = 300,
    DetectionChance = 25,
    DetectionIntervalSeconds = 10,
    MaxActiveDisguises = 1,
    GuardChallengeChance = 35,
    GuardChallengeCooldownSeconds = 20,
    AlertJobs = {
        police = true
    }
}

Config.RestrictedAreas = {
    {
        name = 'Mission Row Police Station',
        coords = vector3(428.23, -984.28, 30.71),
        radius = 50.0,
        requiredDisguise = 'police'
    },
    {
        name = 'Pillbox Medical Centre',
        coords = vector3(304.27, -600.33, 43.28),
        radius = 50.0,
        requiredDisguise = 'ambulance'
    }
}

Config.DisguiseOutfits = {
    police = {
        label = 'Police uniform',
        drawable = 55,
        texture = 0
    },
    ambulance = {
        label = 'Medical uniform',
        drawable = 70,
        texture = 0
    }
}

Config.AdminJobs = {
    admin = true,
    manager = true
}