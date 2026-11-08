local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_qbcore:notify', function(message, notificationType)
    QBCore.Functions.Notify(message or '', notificationType or 'primary')
end)

exports('getQbCore', function()
    return QBCore
end)
