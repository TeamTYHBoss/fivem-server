local plateTransferMenuOpen = false

local function openPlateTransferMenu(data)
    if plateTransferMenuOpen then
        return
    end

    plateTransferMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        vehicles = data.vehicles,
        transfers = data.transfers
    })
end

local function closePlateTransferMenu()
    if not plateTransferMenuOpen then
        return
    end

    plateTransferMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_plate_transfer:openMenu', openPlateTransferMenu)

RegisterNetEvent('whellco_plate_transfer:closeMenu', closePlateTransferMenu)

RegisterNetEvent('whellco_plate_transfer:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('platetransfer', function()
    TriggerServerEvent('whellco_plate_transfer:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_plate_transfer:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('transferPlate', function(data, cb)
    TriggerServerEvent('whellco_plate_transfer:transferPlate', data.vehicleId, data.targetId, data.plate)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
