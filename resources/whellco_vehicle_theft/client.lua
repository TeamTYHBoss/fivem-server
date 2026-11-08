local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_vehicle_theft:startHotwire', function(data)
    if not data or not data.duration then
        return
    end

    QBCore.Functions.Progressbar('hotwiring_vehicle', 'Hotwiring vehicle...', data.duration * 1000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
    }, {}, {}, {}, function()
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

        TriggerServerEvent('whellco_vehicle_theft:complete', coords)
    end, function()
        QBCore.Functions.Notify('Hotwiring cancelled.', 'error')
    end)
end)

RegisterNetEvent('whellco_vehicle_theft:alert', function(data)
    if not data then
        return
    end

    QBCore.Functions.Notify(
        ('Vehicle theft alert: %s driving %s.'):format(data.thiefName, data.plate),
        'error',
        10000
    )
end)

RegisterCommand('theftinfo', function()
    QBCore.Functions.Notify('Use /hotwire while in an unowned vehicle. Police will receive a theft alert.', 'primary')
end, false)