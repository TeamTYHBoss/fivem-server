local validModels = {
    male = true,
    female = true
}

RegisterNetEvent('whellco_wardrobe:confirm', function(appearance)
    local source = source

    if type(appearance) ~= 'table' then
        return
    end

    local model = validModels[appearance.model] and appearance.model or 'male'

    appearance.model = model

    -- Store this in MySQL, a JSON file, or your framework's identity system.
    -- For now, return it to the client and open the spawn selector.
    TriggerClientEvent('whellco_wardrobe:confirmed', source, appearance)

    SetTimeout(500, function()
        TriggerClientEvent('whellco_spawn_selector:open', source)
    end)
end)
