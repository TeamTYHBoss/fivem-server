Config = {}

Config.Timezone = 'Europe/London'
Config.SyncInterval = 60000
Config.WeatherChangeInterval = 900000

Config.Houses = {
    {
        id = 'house_1',
        label = 'House',
        coords = vector3(-268.0, -955.0, 31.0),
        lightDistance = 50.0,
        tvWindowCount = 2,
        tvColour = { r = 0.3, g = 0.5, b = 1.0 },
        windows = {
            vector3(-268.0, -953.0, 32.0),
            vector3(-270.0, -953.0, 32.0),
            vector3(-266.0, -953.0, 32.0)
        },
        curtains = {
            {
                model = 'prop_curtain_01',
                x = -268.0,
                y = -953.0,
                z = 32.0,
                heading = 0.0
            },
            {
                model = 'prop_blind_01',
                x = -270.0,
                y = -953.0,
                z = 32.0,
                heading = 0.0
            }
        },
        silhouettes = {
            {
                model = 'prop_human_seat_chair_03',
                x = -268.0,
                y = -954.0,
                z = 32.0,
                heading = 0.0
            },
            {
                model = 'prop_human_seat_chair_03',
                x = -270.0,
                y = -954.0,
                z = 32.0,
                heading = 0.0
            }
        },
        npcs = {
            {
                model = 'a_m_y_business_01',
                x = -268.0,
                y = -956.0,
                z = 31.0,
                heading = 0.0
            }
        },
        items = {
            {
                model = 'prop_ld_flow_bin',
                x = -268.0,
                y = -957.0,
                z = 31.0,
                heading = 0.0
            }
        }
    }
}

Config.SwimmingPools = {
    {
        id = 'pool_1',
        label = 'Swimming Pool',
        coords = vector3(-268.0, -960.0, 31.0),
        activateDistance = 50.0,
        maxNpcs = 4,
        npcChance = 60,
        npcs = {
            {
                model = 'a_f_y_bevhills_02',
                x = -268.0,
                y = -960.0,
                z = 30.0,
                heading = 0.0,
                swimming = true
            },
            {
                model = 'a_m_y_beach_01',
                x = -270.0,
                y = -960.0,
                z = 30.0,
                heading = 0.0,
                swimming = true
            },
            {
                model = 'a_f_y_tourist_01',
                x = -266.0,
                y = -960.0,
                z = 30.0,
                heading = 0.0,
                swimming = true
            },
            {
                model = 'a_m_y_stbla_02',
                x = -268.0,
                y = -962.0,
                z = 31.0,
                heading = 0.0,
                swimming = false
            }
        }
    }
}

Config.WeatherTypes = {
    'CLEAR',
    'EXTRASUNNY',
    'CLOUDS',
    'OVERCAST',
    'RAIN',
    'CLEARING',
    'THUNDER',
    'SMOG',
    'FOGGY',
    'SNOW',
    'BLIZZARD',
    'SNOWLIGHT',
    'HALLOWEEN'
}

Config.RealisticWeather = {
    {
        type = 'CLEAR',
        weight = 30
    },
    {
        type = 'EXTRASUNNY',
        weight = 20
    },
    {
        type = 'CLOUDS',
        weight = 20
    },
    {
        type = 'OVERCAST',
        weight = 15
    },
    {
        type = 'RAIN',
        weight = 10
    },
    {
        type = 'CLEARING',
        weight = 5
    }
}

Config.SeasonalWeather = {
    {
        month = 12,
        types = {
            { type = 'SNOW', weight = 20 },
            { type = 'SNOWLIGHT', weight = 20 },
            { type = 'BLIZZARD', weight = 5 },
            { type = 'OVERCAST', weight = 20 },
            { type = 'CLOUDS', weight = 20 },
            { type = 'CLEAR', weight = 15 }
        }
    },
    {
        month = 1,
        types = {
            { type = 'SNOW', weight = 20 },
            { type = 'SNOWLIGHT', weight = 20 },
            { type = 'BLIZZARD', weight = 5 },
            { type = 'OVERCAST', weight = 20 },
            { type = 'CLOUDS', weight = 20 },
            { type = 'CLEAR', weight = 15 }
        }
    },
    {
        month = 2,
        types = {
            { type = 'SNOWLIGHT', weight = 15 },
            { type = 'OVERCAST', weight = 20 },
            { type = 'CLOUDS', weight = 25 },
            { type = 'CLEAR', weight = 25 },
            { type = 'RAIN', weight = 15 }
        }
    },
    {
        month = 3,
        types = {
            { type = 'RAIN', weight = 20 },
            { type = 'CLEARING', weight = 15 },
            { type = 'CLOUDS', weight = 25 },
            { type = 'CLEAR', weight = 25 },
            { type = 'EXTRASUNNY', weight = 15 }
        }
    },
    {
        month = 4,
        types = {
            { type = 'RAIN', weight = 15 },
            { type = 'CLEARING', weight = 15 },
            { type = 'CLOUDS', weight = 25 },
            { type = 'CLEAR', weight = 25 },
            { type = 'EXTRASUNNY', weight = 20 }
        }
    },
    {
        month = 5,
        types = {
            { type = 'RAIN', weight = 10 },
            { type = 'CLEARING', weight = 10 },
            { type = 'CLOUDS', weight = 20 },
            { type = 'CLEAR', weight = 30 },
            { type = 'EXTRASUNNY', weight = 30 }
        }
    },
    {
        month = 6,
        types = {
            { type = 'RAIN', weight = 10 },
            { type = 'CLEARING', weight = 10 },
            { type = 'CLOUDS', weight = 20 },
            { type = 'CLEAR', weight = 30 },
            { type = 'EXTRASUNNY', weight = 30 }
        }
    },
    {
        month = 7,
        types = {
            { type = 'RAIN', weight = 5 },
            { type = 'CLEARING', weight = 5 },
            { type = 'CLOUDS', weight = 15 },
            { type = 'CLEAR', weight = 35 },
            { type = 'EXTRASUNNY', weight = 40 }
        }
    },
    {
        month = 8,
        types = {
            { type = 'RAIN', weight = 5 },
            { type = 'CLEARING', weight = 5 },
            { type = 'CLOUDS', weight = 15 },
            { type = 'CLEAR', weight = 35 },
            { type = 'EXTRASUNNY', weight = 40 }
        }
    },
    {
        month = 9,
        types = {
            { type = 'RAIN', weight = 10 },
            { type = 'CLEARING', weight = 10 },
            { type = 'CLOUDS', weight = 20 },
            { type = 'CLEAR', weight = 30 },
            { type = 'EXTRASUNNY', weight = 30 }
        }
    },
    {
        month = 10,
        types = {
            { type = 'RAIN', weight = 15 },
            { type = 'CLEARING', weight = 15 },
            { type = 'CLOUDS', weight = 25 },
            { type = 'CLEAR', weight = 25 },
            { type = 'EXTRASUNNY', weight = 20 }
        }
    },
    {
        month = 11,
        types = {
            { type = 'RAIN', weight = 20 },
            { type = 'CLEARING', weight = 15 },
            { type = 'CLOUDS', weight = 25 },
            { type = 'CLEAR', weight = 25 },
            { type = 'EXTRASUNNY', weight = 15 }
        }
    }
}