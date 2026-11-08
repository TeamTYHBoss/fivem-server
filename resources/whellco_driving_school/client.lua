local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_driving_school:lessonStarted', function(data)
    if not data then
        return
    end

    if data.vehicle and data.spawn then
        local playerPed = PlayerPedId()

        QBCore.Functions.SpawnVehicle(data.vehicle, function(vehicle)
            SetPedIntoVehicle(playerPed, vehicle, -1)
            SetVehicleEngineOn(vehicle, true, true, false)
            SetEntityAsMissionEntity(vehicle, true, true)
        end, data.spawn, true, false)
    end

    QBCore.Functions.Notify(
        ('%s started. Complete the checkpoints.'):format(data.label or 'Driving lesson'),
        'primary'
    )
end)

RegisterNetEvent('whellco_driving_school:lessonCompleted', function(data)
    if not data then
        return
    end

    QBCore.Functions.Notify(
        data.passed and ('%s completed.'):format(data.lessonType or 'Driving lesson') or ('%s failed.'):format(data.lessonType or 'Driving lesson'),
        data.passed and 'success' or 'error'
    )
end)

RegisterCommand('drivingschoolinfo', function()
    QBCore.Functions.Notify(
        'Driving school offers basic, advanced, and defensive driving lessons.',
        'primary'
    )
end, false)