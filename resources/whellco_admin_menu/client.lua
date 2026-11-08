local QBCore = exports['qb-core']:GetCoreObject()

local menuOpen = false
local noclipEnabled = false

RegisterNetEvent('whellco_admin_menu:open', function()
    menuOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open' })
end)

RegisterNUICallback('close', function(_, cb)
    menuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    cb('ok')
end)

RegisterNUICallback('action', function(data, cb)
    TriggerServerEvent('whellco_admin_menu:action', data.action, data.target, data.value)
    cb('ok')
end)

RegisterNetEvent('whellco_admin_menu:godmode', function(enabled)
    local playerPed = PlayerPedId()

    SetEntityInvincible(playerPed, enabled)
    SetPlayerInvincible(PlayerId(), enabled)

    QBCore.Functions.Notify(enabled and 'God mode enabled.' or 'God mode disabled.', enabled and 'success' or 'primary')
end)

RegisterNetEvent('whellco_admin_menu:invisibility', function(enabled)
    SetEntityVisible(PlayerPedId(), not enabled, false)

    QBCore.Functions.Notify(enabled and 'Invisibility enabled.' or 'Invisibility disabled.', enabled and 'success' or 'primary')
end)

RegisterNetEvent('whellco_admin_menu:noclip', function(enabled)
    noclipEnabled = enabled

    local playerPed = PlayerPedId()

    SetEntityCollision(playerPed, not enabled, true)
    SetEntityInvincible(playerPed, enabled)

    QBCore.Functions.Notify(enabled and 'Noclip enabled.' or 'Noclip disabled.', enabled and 'success' or 'primary')
end)

RegisterNetEvent('whellco_admin_menu:heal', function()
    local playerPed = PlayerPedId()

    SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))

    QBCore.Functions.Notify('You have been healed by staff.', 'success')
end)

RegisterNetEvent('whellco_admin_menu:revive', function()
    local playerPed = PlayerPedId()

    if IsEntityDead(playerPed) then
        ResurrectPed(playerPed)
    end

    SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))

    QBCore.Functions.Notify('You have been revived by staff.', 'success')
end)

RegisterNetEvent('whellco_admin_menu:freeze', function(enabled)
    FreezeEntityPosition(PlayerPedId(), enabled)

    QBCore.Functions.Notify(enabled and 'You have been frozen by staff.' or 'You have been unfrozen.', enabled and 'error' or 'success')
end)

RegisterNetEvent('whellco_admin_menu:inventory', function(data)
    if not data then
        return
    end

    QBCore.Functions.Notify(
        ('Inventory view: %s has %s items.'):format(data.targetName, #data.inventory),
        'primary'
    )
end)

CreateThread(function()
    while true do
        Wait(0)

        if noclipEnabled then
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local forward = GetEntityForwardVector(playerPed)
            local speed = IsControlPressed(0, 21) and 8.0 or 2.0

            if IsControlPressed(0, 32) then
                coords = coords + forward * speed
            end

            if IsControlPressed(0, 33) then
                coords = coords - forward * speed
            end

            if IsControlPressed(0, 34) then
                coords = coords - GetEntityRightVector(playerPed) * speed
            end

            if IsControlPressed(0, 35) then
                coords = coords + GetEntityRightVector(playerPed) * speed
            end

            if IsControlPressed(0, 22) then
                coords = coords + vector3(0.0, 0.0, speed)
            end

            if IsControlPressed(0, 36) then
                coords = coords - vector3(0.0, 0.0, speed)
            end

            SetEntityCoords(playerPed, coords.x, coords.y, coords.z, false, false, false, false)
        else
            Wait(250)
        end
    end
end)

RegisterCommand('adminmenuinfo', function()
    QBCore.Functions.Notify('Use /adminmenu or F6 to open the admin menu.', 'primary')
end, false)