local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_lockpick_alerts:alert', function(data)
    if not data then
        return
    end

    QBCore.Functions.Notify(
        ('Failed lockpick alert: %s using %s at %s.'):format(
            data.suspectName,
            data.lockpickType,
            tostring(data.coords)
        ),
        'error',
        10000
    )
end)

RegisterCommand('lockpickalertinfo', function()
    QBCore.Functions.Notify('Failed lockpick attempts can alert nearby police.', 'primary')
end, false)