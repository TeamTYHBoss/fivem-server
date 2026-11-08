Config = {}

Config.Debug = false

Config.CurrencySymbol = '$'
Config.MaxTransactionAmount = 250000
Config.CooldownSeconds = 10
Config.LaunderFeePercent = 15
Config.MinLaunderAmount = 100

Config.BlackMarket = {
    location = vector3(-1172.0, -1568.0, 4.6),
    label = 'Black Market',
    items = {
        lockpick = { price = 750, stock = 10 },
        repairkit = { price = 1500, stock = 5 },
        weapon_attachment = { price = 2500, stock = 3 },
        encrypted_phone = { price = 5000, stock = 2 }
    }
}

Config.Laundering = {
    location = vector3(-616.0, -1613.0, 27.0),
    label = 'Laundromat',
    minAmount = 100,
    maxAmount = 100000,
    cooldownSeconds = 30
}

Config.AllowedJobs = {
    'police'
}