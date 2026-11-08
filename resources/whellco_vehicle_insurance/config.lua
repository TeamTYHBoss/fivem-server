Config = {}

Config.Debug = false

Config.CurrencySymbol = '$'
Config.ClaimCooldownMinutes = 30
Config.MaxClaimAmount = 50000
Config.DamageThreshold = 250
Config.DeductiblePercent = 15

Config.InsuranceOffice = {
    label = 'Wheller Insurance Office',
    location = vector3(-97.8, -1328.4, 29.3),
    radius = 10.0
}

Config.Policies = {
    basic = {
        label = 'Basic Coverage',
        monthlyPrice = 1000,
        maxPayout = 15000
    },
    standard = {
        label = 'Standard Coverage',
        monthlyPrice = 2500,
        maxPayout = 30000
    },
    premium = {
        label = 'Premium Coverage',
        monthlyPrice = 5000,
        maxPayout = 50000
    }
}