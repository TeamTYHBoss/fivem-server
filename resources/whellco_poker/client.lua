local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_poker:result', function(data)
    if not data then
        return
    end

    local message = ('Poker result: %s vs %s. Payout: $%s.'):format(
        data.playerHand,
        data.dealerHand,
        data.payout
    )

    QBCore.Functions.Notify(message, data.result == 'win' and 'success' or data.result == 'push' and 'primary' or 'error')
end)

RegisterCommand('pokerinfo', function()
    QBCore.Functions.Notify('Use /poker [bet] to play poker at the casino table.', 'primary')
end, false)