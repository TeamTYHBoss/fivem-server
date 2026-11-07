local function getPlayerCount()
    local count = 0

    for _ in pairs(GetPlayers()) do
        count = count + 1
    end

    return count
end

CreateThread(function()
    while true do
        local playerCount = getPlayerCount()
        local maxPlayers = GetConvarInt('sv_maxclients', 32)

        TriggerClientEvent('whellco_server_info:update', -1, {
            players = playerCount,
            maxPlayers = maxPlayers
        })

        Wait(5000)
    end
end)

AddEventHandler('playerConnecting', function()
    TriggerClientEvent('whellco_server_info:update', -1, {
        players = getPlayerCount() + 1,
        maxPlayers = GetConvarInt('sv_maxclients', 32)
    })
end)
