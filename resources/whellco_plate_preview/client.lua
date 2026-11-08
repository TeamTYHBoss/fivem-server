local platePreviewMenuOpen = false

local function openPlatePreviewMenu(data)
    if platePreviewMenuOpen then
        return
    end

    platePreviewMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        vehicles = data.vehicles,
        previews = data.previews,
        types = data.types,
        colors = data.colors
    })
end

local function closePlatePreviewMenu()
    if not platePreviewMenuOpen then
        return
    end

    platePreviewMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_plate_preview:openMenu', openPlatePreviewMenu)

RegisterNetEvent('whellco_plate_preview:closeMenu', closePlatePreviewMenu)

RegisterNetEvent('whellco_plate_preview:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('platepreview', function()
    TriggerServerEvent('whellco_plate_preview:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_plate_preview:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('previewPlate', function(data, cb)
    TriggerServerEvent('whellco_plate_preview:previewPlate', data.vehicleId, data.typeId, data.colorId, data.plateText)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
