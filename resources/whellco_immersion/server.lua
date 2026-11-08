local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_immersion:startActivity', function(activityId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local activity = Config.Activities[activityId]

    if not Player or not activity then
        return
    end

    TriggerClientEvent('whellco_immersion:activityStarted', source, {
        id = activityId,
        label = activity.label
    })

    TriggerClientEvent('QBCore:Notify', source, ('Started %s.'):format(activity.label), 'primary')
end)

RegisterNetEvent('whellco_immersion:completeActivity', function(activityId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local activity = Config.Activities[activityId]

    if not Player or not activity then
        return
    end

    if not Player.Functions.AddMoney('bank', activity.payout, ('Completed %s'):format(activity.label)) then
        return
    end

    TriggerClientEvent('QBCore:Notify', source, ('Activity complete. £%d added to bank.'):format(activity.payout), 'success')
end)