local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_vehicle_transfer:transferVehicle', function(vehicleId, targetCitizenId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    targetCitizenId = tostring(targetCitizenId or '')

    if #targetCitizenId == 0 then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid target citizen ID.', 'error')
        return
    end

    local owned = MySQL.scalar.await(
        [[
            SELECT COUNT(*)
            FROM player_vehicles
            WHERE citizenid = ?
              AND id = ?
        ]],
        { Player.PlayerData.citizenid, vehicleId }
    )

    if not owned or owned == 0 then
        TriggerClientEvent('QBCore:Notify', source, 'You do not own this vehicle.', 'error')
        return
    end

    MySQL.update.await(
        [[
            UPDATE player_vehicles
            SET citizenid = ?
            WHERE id = ?
        ]],
        { targetCitizenId, vehicleId }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Vehicle transferred.', 'success')
end)