local plateHistoryMenuOpen = false

local function openPlateHistoryMenu(data)
    if plateHistoryMenuOpen then
        return
    end

    plateHistoryMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        history = data.history
    })
end

local function closePlateHistoryMenu()
    if not plateHistoryMenuOpen then
        return
    end

    plateHistoryMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_plate_history:openMenu', openPlateHistoryMenu)

RegisterNetEvent('whellco_plate_history:closeMenu', closePlateHistoryMenu)

RegisterNetEvent('whellco_plate_history:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('platehistory', function()
    TriggerServerEvent('whellco_plate_history:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_plate_history:closeMenu')
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
