local QBCore = exports['qb-core']:GetCoreObject()

AddEventHandler('playerConnecting', function()
    local source = source

    SetTimeout(3000, function()
        local Player = QBCore.Functions.GetPlayer(source)

        if not Player then
            return
        end

        TriggerClientEvent('whellco_spawn_selector:open', source)
    end)
end)

RegisterNetEvent('whellco_spawn_selector:selectSpawn', function(spawnId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    TriggerClientEvent('whellco_spawn_selector:spawned', source, {
        spawnId = spawnId,
        citizenid = Player.PlayerData.citizenid
    })
end)