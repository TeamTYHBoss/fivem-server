local QBCore = exports['qb-core']:GetCoreObject()

local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

RegisterNetEvent('whellco_mot:bookMot', function(vehicleId)
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    local cost = Config.MotCost or 1500

    if not Player.Functions.RemoveMoney('bank', cost, 'Vehicle MOT booking') then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have enough money.', 'error')
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_mot_records
                (character_id, vehicle_id, cost)
            VALUES (?, ?, ?)
        ]],
        { Player.PlayerData.citizenid, vehicleId, cost }
    )

    TriggerClientEvent('QBCore:Notify', source, 'MOT booked.', 'success')
end)