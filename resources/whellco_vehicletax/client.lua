local taxMenuOpen = false

local function openTaxMenu(data)
    if taxMenuOpen then
        return
    end

    taxMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        vehicles = data.vehicles,
        taxRecords = data.taxRecords,
        penalties = data.penalties
    })
end

local function closeTaxMenu()
    if not taxMenuOpen then
        return
    end

    taxMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_vehicletax:openMenu', openTaxMenu)

RegisterNetEvent('whellco_vehicletax:closeMenu', closeTaxMenu)

RegisterNetEvent('whellco_vehicletax:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('vehicletax', function()
    TriggerServerEvent('whellco_vehicletax:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_vehicletax:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('payTax', function(data, cb)
    TriggerServerEvent('whellco_vehicletax:payTax', data.vehicleId)
    cb({ ok = true })
end)

RegisterNuiCallback('payPenalty', function(data, cb)
    TriggerServerEvent('whellco_vehicletax:payPenalty', data.penaltyId)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
