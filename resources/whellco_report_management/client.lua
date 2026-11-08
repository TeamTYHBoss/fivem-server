local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand('reportmanagementinfo', function()
    QBCore.Functions.Notify('Use /reporthelp to view report management commands.', 'primary')
end, false)