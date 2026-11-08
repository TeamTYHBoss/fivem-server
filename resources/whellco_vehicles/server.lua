local QBCore = exports['qb-core']:GetCoreObject()

local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

local function sendVehicles(source)
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    local vehicles = MySQL.query.await(
        [[
            SELECT id, plate, model, owner_identifier, stored
            FROM whellco_vehicles
            WHERE owner_identifier = ?
            ORDER BY id ASC
        ]],
        { Player.PlayerData.citizenid }
    ) or {}

    TriggerClientEvent('whellco_vehicles:openGarage', source, {
        vehicles = vehicles
    })
end

RegisterNetEvent('whellco_vehicles:openGarage', function()
    local source = source

    sendVehicles(source)
end)

RegisterNetEvent('whellco_vehicles:closeGarage', function()
    TriggerClientEvent('whellco_vehicles:closeGarage', source)
end)

RegisterNetEvent('whellco_vehicles:storeVehicle', function(vehicleId)
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    MySQL.update.await(
        [[
            UPDATE whellco_vehicles
            SET stored = 1
            WHERE id = ? AND owner_identifier = ?
        ]],
        { vehicleId, Player.PlayerData.citizenid }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Vehicle stored.', 'success')

    sendVehicles(source)
end)

RegisterNetEvent('whellco_vehicles:retrieveVehicle', function(vehicleId)
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    MySQL.update.await(
        [[
            UPDATE whellco_vehicles
            SET stored = 0
            WHERE id = ? AND owner_identifier = ?
        ]],
        { vehicleId, Player.PlayerData.citizenid }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Vehicle retrieved.', 'success')

    sendVehicles(source)
end)