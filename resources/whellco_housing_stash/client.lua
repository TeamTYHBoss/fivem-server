local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_housing_stash:enter', function(data)
    if not data or not data.coords then
        return
    end

    local playerPed = PlayerPedId()

    SetEntityCoords(playerPed, data.coords.x, data.coords.y, data.coords.z, false, false, false, false)
    QBCore.Functions.Notify(('Entered %s.'):format(data.label or 'property'), 'success')
end)

RegisterNetEvent('whellco_housing_stash:openStash', function(data)
    if not data then
        return
    end

    QBCore.Functions.Notify(
        ('%s stash opened with %d slot(s).'):format(data.label or 'Property', data.slots or 0),
        'primary'
    )
end)

RegisterCommand('openstash', function(_, args)
    local propertyId = args[1]

    if not propertyId then
        QBCore.Functions.Notify('Usage: /openstash [property_id]', 'error')
        return
    end

    TriggerServerEvent('whellco_housing_stash:openStash', propertyId)
end, false)

RegisterCommand('enterproperty', function(_, args)
    local propertyId = args[1]

    if not propertyId then
        QBCore.Functions.Notify('Usage: /enterproperty [property_id]', 'error')
        return
    end

    TriggerServerEvent('whellco_housing_stash:enter', propertyId)
end, false)