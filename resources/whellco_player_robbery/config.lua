Config = {}

Config.Debug = false

Config.Robbery = {
    RequiredWeapon = 'WEAPON_UNARMED',
    MaxDistance = 2.5,
    MinigameDurationMs = 8000,
    SuccessChance = 65,
    CooldownSeconds = 300,
    MaxCashPerRobbery = 5000,
    MinCashPerRobbery = 100,
    MaxItemsPerRobbery = 3,
    AlertPolice = true,
    AlertPoliceChance = 40,
    AlertPoliceRadius = 100.0,
    RequireHandsUp = true,
    HandsUpKey = 'X',
    HandsUpTimeoutSeconds = 10
}

Config.RobberyItems = {
    'phone',
    'water_bottle',
    'lockpick'
}

Config.ProtectedJobs = {
    police = true,
    ambulance = true
}

Config.AdminJobs = {
    admin = true,
    manager = true
}