Config = {}

Config.Debug = false

Config.CurrencySymbol = '$'
Config.InteractionDistance = 3.0
Config.LessonCooldownMinutes = 5

Config.School = {
    label = 'Wheller Driving School',
    location = vector3(240.4, -1379.2, 33.7),
    radius = 10.0,
    vehicleSpawn = vector4(235.0, -1380.0, 30.4, 250.0)
}

Config.InstructorJob = 'drivinginstructor'

Config.LessonVehicle = 'blista'

Config.LessonTypes = {
    basic = {
        label = 'Basic Driving Lesson',
        price = 500,
        duration = 300
    },
    advanced = {
        label = 'Advanced Driving Lesson',
        price = 1000,
        duration = 600
    },
    defensive = {
        label = 'Defensive Driving Lesson',
        price = 1500,
        duration = 900
    }
}

Config.Checkpoints = {
    vector4(215.0, -1400.0, 30.0, 90.0),
    vector4(120.0, -1390.0, 29.0, 90.0),
    vector4(50.0, -1390.0, 29.0, 90.0),
    vector4(-50.0, -1400.0, 29.0, 90.0),
    vector4(-150.0, -1390.0, 29.0, 90.0),
    vector4(-250.0, -1400.0, 29.0, 90.0)
}