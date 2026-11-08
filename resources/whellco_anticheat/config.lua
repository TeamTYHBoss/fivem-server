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

-- Graduated enforcement. Automatic permanent bans are enabled by default.
-- High-confidence detections create an audit record before enforcement.
Config.Enforcement = {
    WarnThreshold = 20,
    KickThreshold = 50,
    QuarantineThreshold = 80,
    PermanentBanThreshold = 100,
    AutomaticPermanentBan = true,
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

-- Whitelisted detections are ignored to prevent common false positives.
-- Use narrowly and review regularly; do not whitelist broad exploit categories.
Config.FalsePositiveWhitelist = {
    Teleport = {
        -- Examples: interiors, elevators, job teleports, and scripted transitions
        locations = {
            vector3(127.3, -1299.9, 29.3),
            vector3(950.0, 50.0, 70.0),
            vector3(950.0, 60.0, 70.0),
            vector3(950.0, 70.0, 70.0)
        },
        radius = 25.0
    },
    Money = {
        -- Legitimate high-value transactions should be explicitly allowlisted.
        contexts = {
            'salary',
            'business-payout',
            'bank-transfer'
        },
        maxAmount = 250000
    },
    Items = {
        -- Common legitimate item grants
        items = {
            'water_bottle',
            'coffee',
            'repairkit',
            'lockpick'
        },
        maxAmount = 50
    },
    Vehicles = {
        -- Job or scripted vehicle models that may spawn repeatedly
        models = {
            'police',
            'ambulance',
            'taxi'
        }
    }
}

Config.AdminJobs = {
    'admin',
    'manager'
}

Config.WebhookURL = '' -- Optional Discord webhook for staff alerts
