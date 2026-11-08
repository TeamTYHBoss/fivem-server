local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_mechanic:repairVehicle', function(vehicleId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    if Player.PlayerData.job.name ~= 'mechanic' then
        TriggerClientEvent('QBCore:Notify', source, 'You are not a mechanic.', 'error')
        return
    end

    TriggerClientEvent('whellco_mechanic:repair', source, {
        vehicleId = vehicleId
    })

    TriggerClientEvent('QBCore:Notify', source, 'Vehicle repair started.', 'primary')
end)

RegisterNetEvent('whellco_mechanic:completeRepair', function(vehicleId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or Player.PlayerData.job.name ~= 'mechanic' then
        return
    end

    TriggerClientEvent('QBCore:Notify', source, 'Vehicle repaired.', 'success')
end)