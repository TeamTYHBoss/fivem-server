local QBCore = exports['qb-core']:GetCoreObject()

local validModels = {
    male = true,
    female = true
}

RegisterNetEvent('whellco_wardrobe:confirm', function(appearance)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or type(appearance) ~= 'table' then
        return
    end

    local model = validModels[appearance.model] and appearance.model or 'male'

    appearance.model = model

    Player.Functions.SetMetaData('whellco_appearance', appearance)

    TriggerClientEvent('whellco_wardrobe:confirmed', source, appearance)

    SetTimeout(500, function()
        TriggerClientEvent('whellco_spawn_selector:open', source)
    end)
end)

RegisterNetEvent('whellco_wardrobe:requestAppearance', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    TriggerClientEvent('whellco_wardrobe:confirmed', source, Player.PlayerData.metadata.whellco_appearance or {
        model = 'male'
    })
end)