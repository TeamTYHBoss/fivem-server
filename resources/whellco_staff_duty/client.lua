local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand('dutyinfo', function()
    QBCore.Functions.Notify('Use /duty to start or end your staff duty session.', 'primary')
end, false)