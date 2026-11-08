local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_medical:revivePlayer', function(targetId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local Target = QBCore.Functions.GetPlayer(targetId)

    if not Player or not Target then
        return
    end

    if Player.PlayerData.job.name ~= 'ambulance' then
        TriggerClientEvent('QBCore:Notify', source, 'You are not an NHS medic.', 'error')
        return
    end

    TriggerClientEvent('whellco_medical:revive', target, true)

    TriggerClientEvent('QBCore:Notify', source, 'Player revived.', 'success')
    TriggerClientEvent('QBCore:Notify', target, 'You have been revived.', 'success')
end)

RegisterNetEvent('whellco_medical:treatPlayer', function(targetId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local Target = QBCore.Functions.GetPlayer(targetId)

    if not Player or not Target then
        return
    end

    if Player.PlayerData.job.name ~= 'ambulance' then
        TriggerClientEvent('QBCore:Notify', source, 'You are not an NHS medic.', 'error')
        return
    end

    TriggerClientEvent('whellco_medical:treated', target, true)

    TriggerClientEvent('QBCore:Notify', source, 'Player treated.', 'success')
    TriggerClientEvent('QBCore:Notify', target, 'You have been treated.', 'success')
end)