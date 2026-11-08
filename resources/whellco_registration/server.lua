local QBCore = exports['qb-core']:GetCoreObject()

local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

RegisterNetEvent('whellco_registration:registerVehicle', function(vehicleId)
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    local cost = Config.RegistrationCost or 5000

    if not Player.Functions.RemoveMoney('cash', cost, 'Vehicle registration') then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have enough cash.', 'error')
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_registrations
                (character_id, vehicle_id, cost)
            VALUES (?, ?, ?)
        ]],
        { Player.PlayerData.citizenid, vehicleId, cost }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Vehicle registered.', 'success')
end)