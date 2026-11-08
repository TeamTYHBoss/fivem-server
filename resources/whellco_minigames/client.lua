local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_minigames:coffee', function(data)
    if not data then
        return
    end

    QBCore.Functions.Notify(
        ('Purchased coffee from %s.'):format(data.label),
        'success'
    )
end)

RegisterNetEvent('whellco_minigames:start', function(gameType)
    QBCore.Functions.Notify(
        ('Starting %s minigame.'):format(gameType),
        'primary'
    )

    Wait(20000)

    local score = math.random(40, 100)

    TriggerServerEvent('whellco_minigames:complete', gameType, score)
end)

RegisterCommand('minigameinfo', function()
    QBCore.Functions.Notify('Use /coffee, /lockpickgame, /hackgame, or /repairgame to play minigames.', 'primary')
end, false)