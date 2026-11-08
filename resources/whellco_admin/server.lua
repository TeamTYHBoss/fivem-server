local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand('whellcoadmin', function(source)
    if source == 0 then
        return
    end

    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    if not QBCore.Functions.HasPermission(source, 'admin') then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have admin permission.', 'error')
        return
    end

    TriggerClientEvent('whellco_admin:openMenu', source, {
        name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        citizenid = Player.PlayerData.citizenid
    })
end, false)

RegisterNetEvent('whellco_admin:giveCash', function(targetId, amount)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local Target = QBCore.Functions.GetPlayer(targetId)

    amount = math.floor(tonumber(amount) or 0)

    if not Player or not Target or amount <= 0 then
        return
    end

    if not QBCore.Functions.HasPermission(source, 'admin') then
        return
    end

    Target.Functions.AddMoney('cash', amount, 'Admin payment')

    TriggerClientEvent('QBCore:Notify', source, ('Gave £%d cash.'):format(amount), 'success')
    TriggerClientEvent('QBCore:Notify', target, ('You received £%d cash.'):format(amount), 'success')
end)

RegisterNetEvent('whellco_admin:giveBank', function(targetId, amount)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local Target = QBCore.Functions.GetPlayer(targetId)

    amount = math.floor(tonumber(amount) or 0)

    if not Player or not Target or amount <= 0 then
        return
    end

    if not QBCore.Functions.HasPermission(source, 'admin') then
        return
    end

    Target.Functions.AddMoney('bank', amount, 'Admin payment')

    TriggerClientEvent('QBCore:Notify', source, ('Gave £%d bank money.'):format(amount), 'success')
    TriggerClientEvent('QBCore:Notify', target, ('You received £%d bank money.'):format(amount), 'success')
end)