Config = {}

Config.Debug = false

-- Adaptive thresholds start conservative and widen only when repeated
-- detections are confirmed as false positives by staff.
Config.Adaptive = {
    Enabled = true,
    LearningWindowMinutes = 60,
    MinimumSamples = 20,
    MaxThresholdIncrease = 50
}

-- Graduated enforcement. Automatic permanent bans are intentionally disabled;
-- high-confidence events quarantine the player and create a staff review case.
Config.Enforcement = {
    WarnThreshold = 20,
    KickThreshold = 50,
    QuarantineThreshold = 80,
    AutomaticPermanentBan = false,
    QuarantineDurationMinutes = 60
}

Config.RateLimits = {
    EventPerMinute = 600,
    MoneyTransactionPerMinute = 30,
    VehicleSpawnPerMinute = 10,
    ItemGivePerMinute = 20
}

Config.Detection = {
    InvalidMoney = true,
    InvalidItem = true,
    ImpossibleMovement = true,
    EventFlood = true,
    WeaponSpawn = true,
    Teleport = true,
    Godmode = true
}

Config.AdminJobs = {
    'admin',
    'manager'
}

Config.WebhookURL = '' -- Optional Discord webhook for staff alerts
