local neonMenuOpen = false

local function openNeonMenu(data)
    if neonMenuOpen then
        return
    end

    neonMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        vehicles = data.vehicles,
        neons = data.neons,
        colors = data.colors,
        styles = data.styles
    })
end

local function closeNeonMenu()
    if not neonMenuOpen then
        return
    end

    neonMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_neon:openMenu', openNeonMenu)

RegisterNetEvent('whellco_neon:closeMenu', closeNeonMenu)

RegisterNetEvent('whellco_neon:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('neon', function()
    TriggerServerEvent('whellco_neon:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_neon:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('applyNeon', function(data, cb)
    TriggerServerEvent('whellco_neon:applyNeon', data.vehicleId, data.colorId, data.styleId)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
