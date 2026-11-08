local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_police:toggleDuty', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local job = Player.PlayerData.job.name

    if job ~= 'police' then
        TriggerClientEvent('QBCore:Notify', source, 'You are not a police officer.', 'error')
        return
    end

    local onDuty = Player.PlayerData.job.onduty

    Player.Functions.SetJobDuty(not onDuty)

    TriggerClientEvent('QBCore:Notify', source, onDuty and 'You are now off duty.' or 'You are now on duty.', 'primary')
end)

RegisterNetEvent('whellco_police:issueFine', function(targetId, amount)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local Target = QBCore.Functions.GetPlayer(targetId)

    amount = math.floor(tonumber(amount) or 0)

    if not Player or not Target or amount <= 0 then
        return
    end

    if Player.PlayerData.job.name ~= 'police' then
        return
    end

    if not Target.Functions.RemoveMoney('bank', amount, 'Police fine') then
        TriggerClientEvent('QBCore:Notify', source, 'The target cannot pay that fine.', 'error')
        return
    end

    TriggerClientEvent('QBCore:Notify', source, ('Fine issued: £%d.'):format(amount), 'success')
    TriggerClientEvent('QBCore:Notify', target, ('You received a £%d police fine.'):format(amount), 'error')
end)