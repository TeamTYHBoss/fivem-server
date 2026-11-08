local collisionMenuOpen = false

local function openCollisionMenu(data)
    if collisionMenuOpen then
        return
    end

    collisionMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        collisions = data.collisions
    })
end

local function closeCollisionMenu()
    if not collisionMenuOpen then
        return
    end

    collisionMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_collision:openMenu', openCollisionMenu)

RegisterNetEvent('whellco_collision:closeMenu', closeCollisionMenu)

RegisterNetEvent('whellco_collision:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('collisions', function()
    TriggerServerEvent('whellco_collision:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_collision:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('repairVehicle', function(data, cb)
    TriggerServerEvent('whellco_collision:repairVehicle', data.collisionId)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
