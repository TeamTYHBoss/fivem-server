local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand('whellcodocs', function(source)
    if source == 0 then
        return
    end

    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    TriggerClientEvent('whellco_docs:openMenu', source, {
        citizenid = Player.PlayerData.citizenid,
        name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    })
end, false)