local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_admin_toolkit:godmode', function(enabled)
    local playerPed = PlayerPedId()

    SetEntityInvincible(playerPed, enabled)
    SetPlayerInvincible(PlayerId(), enabled)

    QBCore.Functions.Notify(enabled and 'God mode enabled.' or 'God mode disabled.', enabled and 'success' or 'primary')
end)

RegisterNetEvent('whellco_admin_toolkit:invisibility', function(enabled)
    local playerPed = PlayerPedId()

    SetEntityVisible(playerPed, not enabled, false)

    QBCore.Functions.Notify(enabled and 'Invisibility enabled.' or 'Invisibility disabled.', enabled and 'success' or 'primary')
end)

RegisterNetEvent('whellco_admin_toolkit:teleport', function(coords)
    if not coords then
        return
    end

    local playerPed = PlayerPedId()

    SetEntityCoords(playerPed, coords.x, coords.y, coords.z, false, false, false, false)

    QBCore.Functions.Notify('Teleported.', 'success')
end)

RegisterNetEvent('whellco_admin_toolkit:inventory', function(data)
    if not data then
        return
    end

    QBCore.Functions.Notify(
        ('Opened inventory view for %s with %s items.'):format(data.targetName, #data.inventory),
        'primary'
    )
end)

RegisterNetEvent('whellco_admin_toolkit:heal', function()
    local playerPed = PlayerPedId()

    SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))

    QBCore.Functions.Notify('You have been healed by staff.', 'success')
end)

RegisterNetEvent('whellco_admin_toolkit:revive', function()
    local playerPed = PlayerPedId()

    if IsEntityDead(playerPed) then
        ResurrectPed(playerPed)
    end

    SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))

    QBCore.Functions.Notify('You have been revived by staff.', 'success')
end)

RegisterNetEvent('whellco_admin_toolkit:freeze', function(enabled)
    local playerPed = PlayerPedId()

    FreezeEntityPosition(playerPed, enabled)

    QBCore.Functions.Notify(enabled and 'You have been frozen by staff.' or 'You have been unfrozen.', enabled and 'error' or 'success')
end)

RegisterCommand('admintoolkit', function()
    QBCore.Functions.Notify('Admin toolkit commands are available to authorised staff.', 'primary')
end, false)