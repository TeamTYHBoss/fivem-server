local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_vehicle_market:openMenu', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local listings = MySQL.query.await(
        [[
            SELECT id, vehicle_id, plate, price, seller_citizenid, created_at
            FROM whellco_vehicle_market
            ORDER BY created_at DESC
            LIMIT 25
        ]]
    ) or {}

    TriggerClientEvent('whellco_vehicle_market:openMenu', source, {
        listings = listings
    })
end)

RegisterNetEvent('whellco_vehicle_market:closeMenu', function()
    TriggerClientEvent('whellco_vehicle_market:closeMenu', source)
end)

RegisterNetEvent('whellco_vehicle_market:listVehicle', function(vehicleId, price)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    price = tonumber(price)

    if not price or price <= 0 then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid listing price.', 'error')
        return
    end

    local vehicle = MySQL.single.await(
        [[
            SELECT id, plate
            FROM player_vehicles
            WHERE citizenid = ?
              AND id = ?
        ]],
        { Player.PlayerData.citizenid, vehicleId }
    )

    if not vehicle then
        TriggerClientEvent('QBCore:Notify', source, 'You do not own this vehicle.', 'error')
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_vehicle_market
                (vehicle_id, plate, price, seller_citizenid)
            VALUES (?, ?, ?, ?)
        ]],
        { vehicleId, vehicle.plate, price, Player.PlayerData.citizenid }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Vehicle listed for sale.', 'success')
end)