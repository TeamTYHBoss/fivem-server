local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_vehicle_windows:setWindows', function(vehicleId, windows)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    if type(windows) ~= 'table' then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid window data.', 'error')
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
            SET windows = ?
            WHERE id = ?
        ]],
        { json.encode(windows), vehicleId }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Vehicle windows updated.', 'success')
end)