Config = {}

Config.Debug = false

Config.Mansions = {
    {
        id = 'vinewood_hills_mansion',
        label = 'Vinewood Hills Mansion',
        price = 5000000,
        sellbackPercent = 70,
        exterior = vector3(-1440.0, -560.0, 31.0),
        interior = vector3(-1440.0, -560.0, 35.0),
        heading = 90.0,
        mloInterior = 'vinewood_hills_mansion',
        garageSlots = 6,
        storageSlots = 200,
        wardrobeSlots = 100,
        maxGuests = 20,
        maxCameras = 8,
        maxSecurityGuards = 4,
        maxMaids = 4
    },
    {
        id = 'pacific_bluffs_mansion',
        label = 'Pacific Bluffs Mansion',
        price = 7500000,
        sellbackPercent = 70,
        exterior = vector3(-2400.0, -1500.0, 25.0),
        interior = vector3(-2400.0, -1500.0, 29.0),
        heading = 180.0,
        mloInterior = 'pacific_bluffs_mansion',
        garageSlots = 8,
        storageSlots = 250,
        wardrobeSlots = 150,
        maxGuests = 30,
        maxCameras = 12,
        maxSecurityGuards = 6,
        maxMaids = 6
    }
}

Config.Staff = {
    security_guard = {
        label = 'Security guard',
        hiringCost = 25000,
        hourlyWage = 500,
        maxPerMansion = 4
    },
    maid = {
        label = 'Maid',
        hiringCost = 15000,
        hourlyWage = 300,
        maxPerMansion = 4
    }
}

Config.Customisation = {
    WallColours = {
        {label = 'Ivory', value = '#f5f5f0'},
        {label = 'Charcoal', value = '#2b2b2b'},
        {label = 'Deep Navy', value = '#1c2b3a'},
        {label = 'Warm Sand', value = '#d8c3a5'}
    },
    FloorStyles = {
        {label = 'Marble', value = 'marble'},
        {label = 'Dark Oak', value = 'dark_oak'},
        {label = 'Polished Concrete', value = 'concrete'},
        {label = 'Velvet Carpet', value = 'carpet'}
    },
    LightingModes = {
        {label = 'Warm Evening', value = 'warm'},
        {label = 'Cool Modern', value = 'cool'},
        {label = 'Candlelight', value = 'candle'},
        {label = 'Party Mode', value = 'party'}
    }
}

Config.AdminJobs = {
    admin = true,
    manager = true
}