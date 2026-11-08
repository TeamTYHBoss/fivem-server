local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_vip_lapdance:start', function(data)
    if not data or not data.animations then
        return
    end

    local playerPed = PlayerPedId()

    RequestAnimDict(data.animations.customer)

    while not HasAnimDictLoaded(data.animations.customer) do
        Wait(10)
    end

    TaskPlayAnim(playerPed, data.animations.customer, 'dance_step', 8.0, -8.0, data.duration * 1000, 1, 0, false, false, false)

    QBCore.Functions.Notify(
        ('%s booked for %d second(s).'):format(data.label, data.duration),
        'success'
    )
end)

RegisterCommand('vipinfo', function()
    QBCore.Functions.Notify('Use /bookvip [vip_1|vip_2] to book a private VIP lap dance room.', 'primary')
end, false)