local QBCore = exports['qb-core']:GetCoreObject()

local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

RegisterNetEvent('whellco_dealership:purchaseVehicle', function(vehicleId)
    local source = source
    local Player = getQbPlayer(source)
    local vehicle = Config.Vehicles[vehicleId]

    if not Player or not vehicle then
        return
    end

    if not Player.Functions.RemoveMoney('bank', vehicle.price, ('Purchased %s'):format(vehicle.label)) then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have enough money.', 'error')
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_dealership_purchases
                (character_id, vehicle_id, price)
            VALUES (?, ?, ?)
        ]],
        { Player.PlayerData.citizenid, vehicleId, vehicle.price }
    )

    TriggerClientEvent('QBCore:Notify', source, ('Purchased %s.'):format(vehicle.label), 'success')
end)