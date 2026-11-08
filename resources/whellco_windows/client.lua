local windowMenuOpen = false

local function openWindowMenu(data)
    if windowMenuOpen then
        return
    end

    windowMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        vehicles = data.vehicles,
        windows = data.windows,
        tints = data.tints,
        colors = data.colors
    })
end

local function closeWindowMenu()
    if not windowMenuOpen then
        return
    end

    windowMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_windows:openMenu', openWindowMenu)

RegisterNetEvent('whellco_windows:closeMenu', closeWindowMenu)

RegisterNetEvent('whellco_windows:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('windows', function()
    TriggerServerEvent('whellco_windows:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_windows:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('applyWindows', function(data, cb)
    TriggerServerEvent('whellco_windows:applyWindows', data.vehicleId, data.tintId, data.colorId)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
