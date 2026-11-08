local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_vehicle_rarity:setRarity', function(vehicleId, rarity)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    rarity = tostring(rarity or '')

    if not Config.RarityLevels[rarity] then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid rarity level.', 'error')
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
            SET rarity = ?
            WHERE id = ?
        ]],
        { rarity, vehicleId }
    )

    TriggerClientEvent('QBCore:Notify', source, ('Vehicle rarity set to %s.'):format(rarity), 'success')
end)