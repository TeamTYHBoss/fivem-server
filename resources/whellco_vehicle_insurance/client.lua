local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand('insuranceinfo', function()
    QBCore.Functions.Notify(
        'Use /insurance to view policies, /buyinsurance [type] to purchase, and /claiminsurance [plate] [damage] [description] to claim.',
        'primary'
    )
end, false)