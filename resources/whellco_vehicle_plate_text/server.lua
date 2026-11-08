local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_vehicle_plate_text:setText', function(vehicleId, text)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    text = tostring(text or ''):upper():sub(1, 8)

    if #text == 0 then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid plate text.', 'error')
        return
    end

    if not text:match('^[%w%s%-]+$') then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid plate text characters.', 'error')
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
        { text, vehicleId }
    )

    TriggerClientEvent('QBCore:Notify', source, ('Plate text updated to %s.'):format(text), 'success')
end)