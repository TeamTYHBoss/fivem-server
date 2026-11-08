local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_vehicle_alarm:ownerAlert', function(data)
    if not data then
        return
    end

    QBCore.Functions.Notify(
        ('Vehicle alarm triggered: %s.'):format(data.plate),
        'error',
        10000
    )
end)

RegisterNetEvent('whellco_vehicle_alarm:policeAlert', function(data)
    if not data then
        return
    end

    QBCore.Functions.Notify(
        ('Vehicle alarm: %s at %s.'):format(data.plate, tostring(data.coords)),
        'error',
        10000
    )
end)

RegisterCommand('alarminfo', function()
    QBCore.Functions.Notify('Use /installalarm [basic|advanced|premium] while in a vehicle. Use /triggeralarm to test.', 'primary')
end, false)