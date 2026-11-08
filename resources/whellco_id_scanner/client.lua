local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_id_scanner:result', function(data)
    if not data then
        return
    end

    local message = data.valid and 'ID valid.' or 'ID invalid or fake.'

    QBCore.Functions.Notify(
        ('%s: %s'):format(data.targetName, message),
        data.valid and 'success' or 'error'
    )
end)

RegisterNetEvent('whellco_id_scanner:scanned', function(data)
    if not data then
        return
    end

    QBCore.Functions.Notify('Your ID was scanned by security.', 'primary')
end)

RegisterCommand('idscannerinfo', function()
    QBCore.Functions.Notify('Use /scanid [player_id] at the club entrance to scan IDs.', 'primary')
end, false)