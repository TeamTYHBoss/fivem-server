local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_blackjack:result', function(data)
    if not data then
        return
    end

    local message = ('Blackjack result: %s. Payout: $%s.'):format(data.result, data.payout)

    QBCore.Functions.Notify(message, data.result == 'win' and 'success' or data.result == 'push' and 'primary' or 'error')
end)

RegisterCommand('blackjackinfo', function()
    QBCore.Functions.Notify('Use /blackjack [bet] to play blackjack at the casino table.', 'primary')
end, false)