local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand('dmvinfo', function()
    QBCore.Functions.Notify(
        ('DMV: %s. License types: car, bike, truck, boat, pilot.'):format(Config.DMV.label),
        'primary'
    )
end, false)