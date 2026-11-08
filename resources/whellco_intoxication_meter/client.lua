local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_intoxication_meter:result', function(data)
    if not data then
        return
    end

    QBCore.Functions.Notify(
        ('%s: %s%% intoxication (%s)'):format(data.targetName, data.value, data.level),
        data.value >= 80 and 'error' or 'primary'
    )
end)

RegisterNetEvent('whellco_intoxication_meter:checked', function(data)
    if not data then
        return
    end

    QBCore.Functions.Notify('Your intoxication level was checked by security.', 'primary')
end)

RegisterCommand('intoxicationinfo', function()
    QBCore.Functions.Notify('Use /intoxication [player_id] to check intoxication levels.', 'primary')
end, false)