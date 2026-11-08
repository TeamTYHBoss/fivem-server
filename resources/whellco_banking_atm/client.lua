local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_banking_atm:openAccount', function(account)
    if not account then
        return
    end

    QBCore.Functions.Notify(
        ('%s account balance: %s%d'):format(
            account.accountType or 'Checking',
            Config.CurrencySymbol,
            account.balance or 0
        ),
        'primary'
    )
end)

RegisterCommand('atmlocations', function()
    QBCore.Functions.Notify(('Nearby ATMs: %d'):format(#Config.ATMLocations), 'primary')
end, false)