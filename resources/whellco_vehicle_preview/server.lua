local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_vehicle_preview:openPreview', function(vehicleId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local vehicle = MySQL.single.await(
        [[
            SELECT id, plate, vehicle, props
            FROM player_vehicles
            WHERE citizenid = ?
              AND id = ?
        ]],
        { Player.PlayerData.citizenid, vehicleId }
    )

    if not vehicle then
        TriggerClientEvent('QBCore:Notify', source, 'Vehicle not found.', 'error')
        return
    end

    TriggerClientEvent('whellco_vehicle_preview:openPreview', source, {
        vehicle = vehicle
    })
end)

RegisterNetEvent('whellco_vehicle_preview:closePreview', function()
    TriggerClientEvent('whellco_vehicle_preview:closePreview', source)
end)