local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_horse_racing:result', function(data)
    if not data then
        return
    end

    local message = data.won and ('%s won! Payout: $%s.'):format(data.horse.name, data.payout) or ('%s did not win. Better luck next time.'):format(data.horse.name)

    QBCore.Functions.Notify(message, data.won and 'success' or 'error')
end)

RegisterCommand('horsebetinfo', function()
    QBCore.Functions.Notify('Use /horsebet [horse_id] [bet] to place a horse racing bet.', 'primary')
end, false)