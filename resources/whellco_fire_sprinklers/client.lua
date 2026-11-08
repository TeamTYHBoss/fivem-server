local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_fire_sprinklers:activate', function(data)
    if not data or not data.zone then
        return
    end

    QBCore.Functions.Notify(
        ('Fire sprinklers activated in %s.'):format(data.zone.label),
        'error',
        10000
    )
end)

RegisterCommand('sprinklerinfo', function()
    QBCore.Functions.Notify('Use /sprinklers [zone_id] to activate fire sprinklers.', 'primary')
end, false)