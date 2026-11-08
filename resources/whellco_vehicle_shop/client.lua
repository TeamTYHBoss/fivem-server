local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_vehicle_shop:vehiclePurchased', function(data)
    if not data or not data.model or not data.plate or not data.spawn then
        return
    end

    local playerPed = PlayerPedId()
    local coords = data.spawn

    QBCore.Functions.SpawnVehicle(data.model, function(vehicle)
        SetVehicleNumberPlateText(vehicle, data.plate)
        SetPedIntoVehicle(playerPed, vehicle, -1)
        SetVehicleEngineOn(vehicle, true, true, false)
        SetEntityAsMissionEntity(vehicle, true, true)
    end, coords, true, false)
end)

RegisterCommand('dealerinfo', function()
    local dealerships = {}

    for id, dealership in pairs(Config.Dealerships) do
        dealerships[#dealerships + 1] = ('%s - %s'):format(id, dealership.label)
    end

    QBCore.Functions.Notify(table.concat(dealerships, ', '), 'primary')
end, false)