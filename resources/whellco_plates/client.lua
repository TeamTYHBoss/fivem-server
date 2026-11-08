local plateMenuOpen = false

local function openPlateMenu(data)
    if plateMenuOpen then
        return
    end

    plateMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        vehicles = data.vehicles,
        plates = data.plates,
        types = data.types,
        colors = data.colors
    })
end

local function closePlateMenu()
    if not plateMenuOpen then
        return
    end

    plateMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_plates:openMenu', openPlateMenu)

RegisterNetEvent('whellco_plates:closeMenu', closePlateMenu)

RegisterNetEvent('whellco_plates:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('plates', function()
    TriggerServerEvent('whellco_plates:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_plates:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('applyPlate', function(data, cb)
    TriggerServerEvent('whellco_plates:applyPlate', data.vehicleId, data.typeId, data.colorId)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
