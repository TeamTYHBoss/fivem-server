local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_report_teleport:go', function(data)
    if not data or not data.coords then
        return
    end

    local playerPed = PlayerPedId()

    SetEntityCoords(
        playerPed,
        data.coords.x,
        data.coords.y,
        data.coords.z,
        false,
        false,
        false,
        false
    )

    QBCore.Functions.Notify(
        ('Teleported to report #%d.'):format(data.reportId),
        'success'
    )
end)

RegisterCommand('gotoreportinfo', function()
    QBCore.Functions.Notify('Use /gotoreport [report_id] to teleport to an open report location.', 'primary')
end, false)