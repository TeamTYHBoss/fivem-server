local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_dance_floor:start', function(data)
    if not data then
        return
    end

    QBCore.Functions.Notify(
        'Dance floor minigame started. Hit the rhythm markers.',
        'primary',
        10000
    )

    Wait(data.duration * 1000)

    local score = math.random(40, 100)

    TriggerServerEvent('whellco_dance_floor:complete', score)
end)

RegisterNetEvent('whellco_dance_floor:result', function(data)
    if not data then
        return
    end

    local message = data.success and ('Great dancing! You earned $%s.'):format(data.reward) or 'Better luck next time.'

    QBCore.Functions.Notify(message, data.success and 'success' or 'error')
end)

RegisterCommand('danceinfo', function()
    QBCore.Functions.Notify('Use /dance to start the dance floor skill check.', 'primary')
end, false)