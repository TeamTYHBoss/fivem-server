AddEventHandler('playerConnecting', function()
    local source = source

    SetTimeout(3000, function()
        TriggerClientEvent('whellco_spawn_selector:open', source)
    end)
end)
