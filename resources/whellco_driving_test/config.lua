Config = {}

Config.Debug = false

Config.CurrencySymbol = '$'
Config.InteractionDistance = 3.0
Config.TestCooldownMinutes = 10
Config.MaxSpeedKmh = 80
Config.MaxFails = 3

Config.TestCenter = {
    label = 'DMV Driving Test Center',
    location = vector3(240.4, -1379.2, 33.7),
    radius = 10.0,
    vehicleSpawn = vector4(235.0, -1380.0, 30.4, 250.0)
}

Config.TestVehicle = 'blista'

Config.Checkpoints = {
    vector4(215.0, -1400.0, 30.0, 90.0),
    vector4(120.0, -1390.0, 29.0, 90.0),
    vector4(50.0, -1390.0, 29.0, 90.0),
    vector4(-50.0, -1400.0, 29.0, 90.0),
    vector4(-150.0, -1390.0, 29.0, 90.0),
    vector4(-250.0, -1400.0, 29.0, 90.0)
}

Config.Penalties = {
    speeding = 1,
    wrongWay = 1,
    collision = 1
}