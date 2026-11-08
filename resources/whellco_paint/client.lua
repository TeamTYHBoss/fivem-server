local paintMenuOpen = false

local function openPaintMenu(data)
    if paintMenuOpen then
        return
    end

    paintMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        vehicles = data.vehicles,
        paints = data.paints,
        colors = data.colors,
        finishes = data.finishes
    })
end

local function closePaintMenu()
    if not paintMenuOpen then
        return
    end

    paintMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_paint:openMenu', openPaintMenu)

RegisterNetEvent('whellco_paint:closeMenu', closePaintMenu)

RegisterNetEvent('whellco_paint:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('paint', function()
    TriggerServerEvent('whellco_paint:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_paint:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('applyPaint', function(data, cb)
    TriggerServerEvent('whellco_paint:applyPaint', data.vehicleId, data.colorId, data.finishId)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
