local QBCore = exports['qb-core']:GetCoreObject()

local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

RegisterNetEvent('whellco_vehicletax:payTax', function(vehicleId)
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    local tax = Config.TaxAmount or 2500

    if not Player.Functions.RemoveMoney('bank', tax, 'Vehicle tax payment') then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have enough money.', 'error')
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_vehicle_taxes
                (character_id, vehicle_id, amount)
            VALUES (?, ?, ?)
        ]],
        { Player.PlayerData.citizenid, vehicleId, tax }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Vehicle tax paid.', 'success')
end)