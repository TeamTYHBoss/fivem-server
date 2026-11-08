local QBCore = exports['qb-core']:GetCoreObject()

local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

RegisterNetEvent('whellco_impound:releaseVehicle', function(vehicleId)
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    local cost = Config.ReleaseCost or 10000

    if not Player.Functions.RemoveMoney('bank', cost, 'Vehicle impound release') then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have enough money.', 'error')
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_impound_records
                (character_id, vehicle_id, cost)
            VALUES (?, ?, ?)
        ]],
        { Player.PlayerData.citizenid, vehicleId, cost }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Vehicle released from impound.', 'success')
end)