local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_patron_blacklist:blacklisted', function(data)
    if not data or not data.ejectLocation then
        return
    end

    local playerPed = PlayerPedId()

    QBCore.Functions.Notify(
        ('You have been blacklisted: %s'):format(data.reason or 'Banned from premises'),
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

RegisterCommand('blacklistinfo', function()
    QBCore.Functions.Notify('Security can blacklist or unblacklist patrons.', 'primary')
end, false)