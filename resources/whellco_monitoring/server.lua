local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand('whellcostatus', function(source)
    local playerCount = #GetPlayers()

    local message = ('WhellCo status: %d players online.'):format(playerCount)

    if source > 0 then
        TriggerClientEvent('QBCore:Notify', source, message, 'primary')
    else
        print(message)
    end
end, false)

RegisterNetEvent('whellco_monitoring:requestStatus', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    TriggerClientEvent('whellco_monitoring:status', source, {
        players = #GetPlayers(),
        citizenid = Player.PlayerData.citizenid
    })
end)