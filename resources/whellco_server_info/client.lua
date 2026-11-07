RegisterNetEvent('whellco_server_info:update', function(data)
    SendLoadingScreenMessage(json.encode({
        eventName = 'whellcoPlayerCount',
        players = data.players or 0,
        maxPlayers = data.maxPlayers or 0
    }))
end)
