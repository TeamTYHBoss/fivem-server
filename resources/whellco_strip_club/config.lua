Config = {}

Config.Debug = false

Config.CurrencySymbol = '$'
Config.InteractionDistance = 2.0
Config.TipCooldownSeconds = 10

Config.StripClub = {
    label = 'Wheller Velvet Lounge',
    location = vector3(127.3, -1299.9, 29.3),
    radius = 30.0,
    entrance = vector3(127.3, -1299.9, 29.3)
}

Config.NPCs = {
    bartender = {
        model = 's_m_m_bartender_01',
        coords = vector4(130.0, -1302.0, 29.3, 250.0),
        scenario = 'WORLD_HUMAN_BARTENDER'
    },
    security = {
        model = 's_m_m_security_01',
        coords = vector4(125.0, -1297.0, 29.3, 70.0),
        scenario = 'WORLD_HUMAN_GUARD_STAND'
    },
    dancer = {
        model = 'a_f_y_hipster_02',
        coords = vector4(132.0, -1305.0, 29.3, 180.0),
        scenario = 'WORLD_HUMAN_PARTYING'
    }
}

Config.Furniture = {
    { model = 'prop_ld_stage01', coords = vector4(132.0, -1305.0, 29.0, 180.0) },
    { model = 'prop_table_03', coords = vector4(128.0, -1300.0, 29.0, 90.0) },
    { model = 'prop_ld_ferris_wheel', coords = vector4(126.0, -1304.0, 29.0, 45.0) },
    { model = 'prop_bench_01a', coords = vector4(129.0, -1298.0, 29.0, 270.0) }
}

Config.Drinks = {
    water = { label = 'Water', price = 25 },
    beer = { label = 'Beer', price = 75 },
    whiskey = { label = 'Whiskey', price = 150 }
}

Config.TipAmount = 100