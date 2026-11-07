Config = {}

Config.Currency = '£'

Config.Shops = {
    legion_247 = {
        label = '24/7 Supermarket',
        coords = vector3(24.4, -1345.7, 29.5),
        items = {
            water = { label = 'Bottled Water', price = 3 },
            sandwich = { label = 'Sandwich', price = 6 },
            energy_drink = { label = 'Energy Drink', price = 5 },
            first_aid = { label = 'First Aid Kit', price = 25 }
        }
    },
    legion_hardware = {
        label = 'Hardware Store',
        coords = vector3(274.8, -1166.9, 29.4),
        items = {
            repair_kit = { label = 'Vehicle Repair Kit', price = 150 },
            lockpick = { label = 'Lockpick', price = 250 },
            toolbox = { label = 'Toolbox', price = 90 }
        }
    },
    legion_clothing = {
        label = 'Clothing Store',
        coords = vector3(72.3, -1399.1, 29.4),
        items = {
            casual_outfit = { label = 'Casual Outfit', price = 250 },
            work_uniform = { label = 'Work Uniform', price = 180 },
            formal_outfit = { label = 'Formal Outfit', price = 500 }
        }
    }
}

Config.Transport = {
    legion_bus_stop = {
        label = 'Legion Square Bus Stop',
        coords = vector3(195.2, -933.8, 30.7),
        destinations = {
            paleto = { label = 'Paleto Bay', price = 250, coords = vector3(-447.9, 6013.6, 31.7) },
            sandy = { label = 'Sandy Shores', price = 200, coords = vector3(1962.3, 3740.7, 32.3) },
            grapeseed = { label = 'Grapeseed', price = 220, coords = vector3(1701.5, 4924.3, 42.1) }
        }
    }
}

Config.Services = {
    police_station = {
        label = 'Mission Row Police Station',
        coords = vector3(428.2, -984.0, 30.7),
        service = 'police'
    },
    hospital = {
        label = 'Pillbox Hill Medical Centre',
        coords = vector3(298.1, -584.4, 43.2),
        service = 'ambulance'
    },
    mechanic = {
        label = 'Bennys Motorworks',
        coords = vector3(-212.1, -1316.8, 30.4),
        service = 'mechanic'
    },
    job_centre = {
        label = 'Job Centre',
        coords = vector3(-269.4, -955.3, 31.2),
        service = 'civilian'
    }
}

Config.Jobs = {
    taxi = {
        label = 'Taxi Driver',
        start = vector3(903.5, -170.3, 74.1),
        vehicle = 'taxi',
        basePayout = 250,
        payoutIncreasePerTier = 125
    },
    delivery = {
        label = 'Delivery Driver',
        start = vector3(-55.7, -1822.8, 26.9),
        vehicle = 'speedo',
        basePayout = 200,
        payoutIncreasePerTier = 100
    },
    refuse = {
        label = 'Refuse Collector',
        start = vector3(-322.1, -1546.5, 31.0),
        vehicle = 'trash',
        basePayout = 180,
        payoutIncreasePerTier = 90
    },
    mechanic = {
        label = 'Mechanic',
        start = vector3(-212.1, -1316.8, 30.4),
        vehicle = 'towtruck',
        basePayout = 275,
        payoutIncreasePerTier = 125
    }
}

Config.JobTiers = {
    { minimumCompleted = 0, stops = 1, timeLimit = 600 },
    { minimumCompleted = 5, stops = 2, timeLimit = 720 },
    { minimumCompleted = 15, stops = 3, timeLimit = 840 },
    { minimumCompleted = 30, stops = 4, timeLimit = 960 },
    { minimumCompleted = 60, stops = 5, timeLimit = 1080 }
}

Config.JobDestinations = {
    vector3(195.2, -933.8, 30.7),
    vector3(-447.9, 6013.6, 31.7),
    vector3(1962.3, 3740.7, 32.3),
    vector3(1701.5, 4924.3, 42.1),
    vector3(298.1, -584.4, 43.2),
    vector3(-212.1, -1316.8, 30.4),
    vector3(428.2, -984.0, 30.7),
    vector3(24.4, -1345.7, 29.5)
}

Config.FuelStations = {
    { label = 'Legion Square Fuel', coords = vector3(69.5, -1381.8, 29.4), pricePerLitre = 180 },
    { label = 'Paleto Fuel', coords = vector3(-2554.9, 3264.6, 32.8), pricePerLitre = 190 }
}

Config.AmbientEvents = {
    { type = 'medical', coords = vector3(298.1, -584.4, 43.2), reward = 400 },
    { type = 'mechanical', coords = vector3(-212.1, -1316.8, 30.4), reward = 350 },
    { type = 'police', coords = vector3(428.2, -984.0, 30.7), reward = 450 }
}
