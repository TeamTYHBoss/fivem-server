Config = {}

Config.Debug = false

Config.CurrencySymbol = '$'
Config.XpPerSuccessfulLockpick = 10
Config.XpPerFailedLockpick = 2
Config.MaxStealthLevel = 3

Config.StealthLevels = {
    [1] = {
        label = 'No Stealth Training',
        xpRequired = 0,
        alertReduction = 0
    },
    [2] = {
        label = 'Basic Stealth Training',
        xpRequired = 50,
        alertReduction = 20
    },
    [3] = {
        label = 'Advanced Stealth Training',
        xpRequired = 150,
        alertReduction = 40
    }
}