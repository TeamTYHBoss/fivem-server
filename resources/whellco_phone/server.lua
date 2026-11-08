local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_phone:openPhone', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    TriggerClientEvent('whellco_phone:open', source, {
        citizenid = Player.PlayerData.citizenid,
        name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        phone = Player.PlayerData.charinfo.phone
    })
end)

RegisterNetEvent('whellco_phone:sendMessage', function(targetId, message)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local Target = QBCore.Functions.GetPlayer(targetId)

    if not Player or not Target or not message then
        return
    end

    TriggerClientEvent('whellco_phone:message', target, {
        sender = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        message = tostring(message):sub(1, 255)
    })

    TriggerClientEvent('QBCore:Notify', source, 'Message sent.', 'success')
end)