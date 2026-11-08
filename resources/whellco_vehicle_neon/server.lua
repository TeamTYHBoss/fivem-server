local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_vehicle_neon:setNeon', function(vehicleId, neon)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    if type(neon) ~= 'table' then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid neon data.', 'error')
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
            SET neon = ?
            WHERE id = ?
        ]],
        { json.encode(neon), vehicleId }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Vehicle neon updated.', 'success')
end)