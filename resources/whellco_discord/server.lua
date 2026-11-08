local QBCore = exports['qb-core']:GetCoreObject()

AddEventHandler('playerConnecting', function(_, _, deferrals)
    local source = source

    deferrals.defer()
    Wait(0)

    local Player = QBCore.Functions.GetPlayer(source)

    deferrals.update('Connecting to WhellCo roleplay…')

    if Player then
        deferrals.done()
    else
        deferrals.done('QBCore is still loading. Please reconnect.')
    end
end)

RegisterNetEvent('whellco_discord:requestIdentity', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    TriggerClientEvent('whellco_discord:identity', source, {
        citizenid = Player.PlayerData.citizenid,
        name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        job = Player.PlayerData.job.label
    })
end)