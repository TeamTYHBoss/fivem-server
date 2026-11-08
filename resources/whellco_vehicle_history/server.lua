local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_vehicle_history:openMenu', function(vehicleId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local history = MySQL.query.await(
        [[
            SELECT id, vehicle_id, action, details, created_at
            FROM whellco_vehicle_history
            WHERE citizenid = ?
              AND vehicle_id = ?
            ORDER BY created_at DESC
            LIMIT 25
        ]],
        { Player.PlayerData.citizenid, vehicleId }
    ) or {}

    TriggerClientEvent('whellco_vehicle_history:openMenu', source, {
        history = history
    })
end)

RegisterNetEvent('whellco_vehicle_history:closeMenu', function()
    TriggerClientEvent('whellco_vehicle_history:closeMenu', source)
end)

RegisterNetEvent('whellco_vehicle_history:recordHistory', function(vehicleId, action, details)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_vehicle_history
                (citizenid, vehicle_id, action, details)
            VALUES (?, ?, ?, ?)
        ]],
        { Player.PlayerData.citizenid, vehicleId, action, details }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Vehicle history recorded.', 'success')
end)