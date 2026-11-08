local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_bartender_minigame:start', function(data)
    if not data then
        return
    end

    QBCore.Functions.Notify(
        ('Mixing %s. Match the ingredients before time runs out.'):format(data.drink.label),
        'primary',
        10000
    )

    Wait(data.duration * 1000)

    local score = math.random(50, 100)

    TriggerServerEvent('whellco_bartender_minigame:complete', data.drink.label, score)
end)

RegisterCommand('mixdrinkinfo', function()
    QBCore.Functions.Notify('Use /mixdrink [drink_id] to start the drink mixing minigame.', 'primary')
end, false)