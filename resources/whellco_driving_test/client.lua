local QBCore = exports['qb-core']:GetCoreObject()

local activeTest = nil
local currentCheckpoint = 1

RegisterNetEvent('whellco_driving_test:start', function(data)
    if not data or not data.vehicle or not data.spawn then
        return
    end

    activeTest = data
    currentCheckpoint = 1

    local playerPed = PlayerPedId()

    QBCore.Functions.SpawnVehicle(data.vehicle, function(vehicle)
        SetPedIntoVehicle(playerPed, vehicle, -1)
        SetVehicleEngineOn(vehicle, true, true, false)
        SetEntityAsMissionEntity(vehicle, true, true)
    end, data.spawn, true, false)

    QBCore.Functions.Notify(
        ('Driving test started. Reach %d checkpoint(s) without exceeding %d km/h.'):format(
            #data.checkpoints,
            data.maxSpeed
        ),
        'primary'
    )
end)

RegisterNetEvent('whellco_driving_test:end', function(data)
    activeTest = nil

    if not data then
        return
    end

    QBCore.Functions.Notify(
        data.passed and ('Driving test passed: %s.'):format(data.reason) or ('Driving test failed: %s.'):format(data.reason),
        data.passed and 'success' or 'error'
    )
end)

RegisterCommand('drivingtestinstructions', function()
    QBCore.Functions.Notify(
        'Use /drivingtest at the DMV. Follow the checkpoints, avoid speeding, collisions, and wrong-way driving.',
        'primary'
    )
end, false)