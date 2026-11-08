local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_roulette:result', function(data)
    if not data then
        return
    end

    local message = ('Roulette result: %d %s %s. Payout: $%s.'):format(
        data.number,
        data.color,
        data.parity,
        data.payout
    )

    QBCore.Functions.Notify(message, data.won and 'success' or 'error')
end)

RegisterCommand('rouletteinfo', function()
    QBCore.Functions.Notify('Use /roulette [number|color|parity] [value] [bet] to play roulette.', 'primary')
end, false)