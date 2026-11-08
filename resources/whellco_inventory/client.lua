local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_inventory:openStorage', function(storage)
    if not storage then
        return
    end

    QBCore.Functions.Notify(
        ('%s opened with %d slot(s).'):format(storage.label or 'Storage', storage.slots or 0),
        'primary'
    )
end)

RegisterCommand('openinventory', function()
    QBCore.Functions.Notify('Player inventory opened.', 'primary')
end, false)