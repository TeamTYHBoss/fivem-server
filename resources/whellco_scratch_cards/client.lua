local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_scratch_cards:result', function(data)
    if not data then
        return
    end

    local message = data.won and ('You won $%s!'):format(data.payout) or 'No prize this time.'

    QBCore.Functions.Notify(message, data.won and 'success' or 'error')
end)

RegisterCommand('scratchinfo', function()
    QBCore.Functions.Notify('Use /scratch to scratch a lottery ticket.', 'primary')
end, false)