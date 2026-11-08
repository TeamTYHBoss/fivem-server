local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_vehicle_plates:setPlate', function(vehicleId, plate)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    plate = tostring(plate or ''):upper():gsub('%s', '')

    if #plate == 0 or #plate > 8 then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid plate length.', 'error')
        return
    end

    if not plate:match('^%w+$') then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid plate characters.', 'error')
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
            SET plate = ?
            WHERE id = ?
        ]],
        { plate, vehicleId }
    )

    TriggerClientEvent('QBCore:Notify', source, ('Plate updated to %s.'):format(plate), 'success')
end)