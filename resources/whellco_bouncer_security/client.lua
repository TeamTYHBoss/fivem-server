local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_bouncer_security:escort', function(data)
    if not data or not data.ejectLocation then
        return
    end

    local playerPed = PlayerPedId()

    QBCore.Functions.Notify(
        ('Security is escorting you out: %s'):format(data.reason or 'Disruptive behaviour'),
        'error',
        10000
    )

    Wait(data.duration * 1000)

    SetEntityCoords(
        playerPed,
        data.ejectLocation.x,
        data.ejectLocation.y,
        data.ejectLocation.z,
        false,
        false,
        false,
        false
    )

    SetEntityHeading(playerPed, data.ejectLocation.w)
end)

RegisterCommand('securityinfo', function()
    QBCore.Functions.Notify('Security guards can escort disruptive players out of the club.', 'primary')
end, false)