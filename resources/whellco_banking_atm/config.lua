Config = {}

Config.Debug = false

Config.CurrencySymbol = '$'
Config.MaxTransactionAmount = 1000000
Config.ATMWithdrawalLimit = 5000
Config.ATMDailyLimit = 25000
Config.TransferFeePercent = 0

Config.ATMLocations = {
    vector4(147.43, -1035.71, 29.34, 340.0),
    vector4(-717.61, -915.87, 19.21, 95.0),
    vector4(-1305.4, -835.99, 17.19, 122.0),
    vector4(24.37, -945.05, 29.14, 178.0),
    vector4(-1131.25, -1301.95, 4.35, 251.0)
}

Config.BankLocations = {
    {
        label = 'Los Santos Bank',
        coords = vector3(149.91, -1040.49, 29.37),
        heading = 340.0
    },
    {
        label = 'Fleeca Bank',
        coords = vector3(-356.05, -50.51, 49.04),
        heading = 252.0
    }
}

Config.AllowedAccounts = {
    'checking',
    'savings',
    'business'
}