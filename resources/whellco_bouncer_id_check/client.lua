local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_bouncer_id_check:result', function(data)
    if not data then
        return
    end

    local message = data.allowed and 'ID valid. Entry approved.' or 'ID invalid or fake. Entry denied.'

    QBCore.Functions.Notify(
        ('%s: %s'):format(data.targetName, message),
        data.allowed and 'success' or 'error'
    )
end)

RegisterNetEvent('whellco_bouncer_id_check:checked', function(data)
    if not data then
        return
    end

    QBCore.Functions.Notify('Your ID was checked by security at the front door.', 'primary')
end)

RegisterCommand('checkidinfo', function()
    QBCore.Functions.Notify('Use /checkid [player_id] at the front door to check IDs.', 'primary')
end, false)