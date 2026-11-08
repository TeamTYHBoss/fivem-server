Config = {}

Config.Debug = false

Config.Performance = {
    TickRateWarningMs = 8.0,
    TickRateCriticalMs = 15.0,
    SampleIntervalSeconds = 5,
    MaxEntitiesPerPlayer = 150,
    MaxPedsPerPlayer = 50,
    MaxVehiclesPerPlayer = 30,
    MaxObjectsPerPlayer = 100
}

Config.RateLimits = {
    EventPerMinute = 600,
    NetEventPerMinute = 300,
    VehicleSpawnPerMinute = 10,
    PedSpawnPerMinute = 20,
    ObjectSpawnPerMinute = 30
}

Config.Enforcement = {
    WarnThreshold = 20,
    KickThreshold = 50,
    AutomaticKick = true
}

Config.AdminJobs = {
    admin = true,
    manager = true
}