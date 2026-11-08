Config = {}

Config.Debug = false

Config.Cleanup = {
    IntervalSeconds = 300,
    VehicleIdleMinutes = 15,
    PedIdleMinutes = 10,
    MaxCleanupPerCycle = 50,
    SkipPlayerVehicles = true,
    SkipMissionEntities = true,
    SkipOwnedVehicles = true
}

Config.ExemptModels = {
    ['police'] = true,
    ['ambulance'] = true,
    ['firetruk'] = true
}

Config.ExemptZones = {
    {name = 'legion-square', coords = vector3(215.0, -810.0, 30.0), radius = 100.0},
    {name = 'paleto-bay', coords = vector3(-448.0, 6013.0, 31.0), radius = 100.0}
}

Config.AdminJobs = {
    admin = true,
    manager = true
}