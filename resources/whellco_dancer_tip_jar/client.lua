local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand('tipinfo', function()
    QBCore.Functions.Notify('Use /tip [dancer_id] [amount] to tip a dancer.', 'primary')
end, false)