local function getPlayerData()
    local players = {}
    local count = 0

    for _, playerId in ipairs(GetPlayers()) do
        count = count + 1

        players[count] = {
            id = playerId,
            name = GetPlayerName(playerId) or 'Unknown Player'
        }
    end

    return players, count
end

CreateThread(function()
    while true do
        local players, playerCount = getPlayerData()
        local maxPlayers = GetConvarInt('sv_maxclients', 32)

        TriggerClientEvent('whellco_server_info:update', -1, {
            players = playerCount,
            maxPlayers = maxPlayers,
            playerNames = players
        })

        Wait(5000)
    end
end)

AddEventHandler('playerConnecting', function()
    local players, playerCount = getPlayerData()

    TriggerClientEvent('whellco_server_info:update', -1, {
        players = playerCount,
        maxPlayers = GetConvarInt('sv_maxclients', 32),
        playerNames = players
    })
end)
