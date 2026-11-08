Config = {}

Config.Currency = '£'

Config.InsurancePlans = {
    basic = {
        label = 'Basic Insurance',
        monthlyPrice = 500,
        claimLimit = 10000,
        deductible = 1000
    },
    standard = {
        label = 'Standard Insurance',
        monthlyPrice = 1000,
        claimLimit = 25000,
        deductible = 500
    },
    premium = {
        label = 'Premium Insurance',
        monthlyPrice = 2000,
        claimLimit = 50000,
        deductible = 250
    }
}

Config.InsuranceOffice = {
    coords = vector3(-100.0, -800.0, 30.0)
}
