local plateTextMenuOpen = false

local function openPlateTextMenu(data)
    if plateTextMenuOpen then
        return
    end

    plateTextMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        vehicles = data.vehicles,
        plates = data.plates
    })
end

local function closePlateTextMenu()
    if not plateTextMenuOpen then
        return
    end

    plateTextMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_plate_text:openMenu', openPlateTextMenu)

RegisterNetEvent('whellco_plate_text:closeMenu', closePlateTextMenu)

RegisterNetEvent('whellco_plate_text:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('platetext', function()
    TriggerServerEvent('whellco_plate_text:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_plate_text:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('applyPlateText', function(data, cb)
    TriggerServerEvent('whellco_plate_text:applyPlateText', data.vehicleId, data.plateText)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
