local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_bouncer_eject:ejected', function(data)
    if not data or not data.ejectLocation then
        return
    end

    local playerPed = PlayerPedId()

    QBCore.Functions.Notify(
        ('You have been ejected: %s'):format(data.reason or 'Removed from premises'),
        'error',
        10000
    )

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

RegisterCommand('ejectinfo', function()
    QBCore.Functions.Notify('Use /eject [player_id] [reason] to eject a player.', 'primary')
end, false)