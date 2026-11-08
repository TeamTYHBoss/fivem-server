local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_vehicle_wheels:setWheels', function(vehicleId, wheels)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    if type(wheels) ~= 'table' then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid wheel data.', 'error')
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
            SET wheels = ?
            WHERE id = ?
        ]],
        { json.encode(wheels), vehicleId }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Vehicle wheels updated.', 'success')
end)