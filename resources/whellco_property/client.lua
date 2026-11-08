local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_property:enter', function(data)
    if not data or not data.coords then
        return
    end

    local playerPed = PlayerPedId()

    SetEntityCoords(playerPed, data.coords.x, data.coords.y, data.coords.z, false, false, false, false)
    QBCore.Functions.Notify(('Entered %s.'):format(data.label or 'property'), 'success')
end)

RegisterNetEvent('whellco_property:exit', function(data)
    if not data or not data.coords then
        return
    end

    local playerPed = PlayerPedId()

    SetEntityCoords(playerPed, data.coords.x, data.coords.y, data.coords.z, false, false, false, false)
    QBCore.Functions.Notify('Exited property.', 'success')
end)

RegisterCommand('propertylock', function(_, args)
    local propertyId = args[1]

    if not propertyId then
        QBCore.Functions.Notify('Usage: /propertylock [property_id]', 'error')
        return
    end

    TriggerServerEvent('whellco_property:toggleLock', propertyId)
end, false)

RegisterCommand('propertykey', function(_, args)
    local propertyId = args[1]
    local targetCitizenId = args[2]

    if not propertyId or not targetCitizenId then
        QBCore.Functions.Notify('Usage: /propertykey [property_id] [citizen_id]', 'error')
        return
    end

    TriggerServerEvent('whellco_property:giveKey', propertyId, targetCitizenId)
end, false)