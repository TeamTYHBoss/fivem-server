local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_strip_club_premium:start', function(data)
    if not data then
        return
    end

    QBCore.Functions.Notify(
        ('Premium private dance started for $%s.'):format(data.price),
        'primary',
        10000
    )

    local playerPed = PlayerPedId()

    TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_PARTYING', 0, true)

    Wait(data.duration * 1000)

    ClearPedTasks(playerPed)
end)

RegisterCommand('premiumdanceinfo', function()
    QBCore.Functions.Notify('Use /premiumdance [dancer_id] to request a premium private dance.', 'primary')
end, false)