local registrationMenuOpen = false

local function openRegistrationMenu(data)
    if registrationMenuOpen then
        return
    end

    registrationMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        vehicles = data.vehicles,
        registrations = data.registrations,
        transfers = data.transfers
    })
end

local function closeRegistrationMenu()
    if not registrationMenuOpen then
        return
    end

    registrationMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_registration:openMenu', openRegistrationMenu)

RegisterNetEvent('whellco_registration:closeMenu', closeRegistrationMenu)

RegisterNetEvent('whellco_registration:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('registration', function()
    TriggerServerEvent('whellco_registration:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_registration:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('registerVehicle', function(data, cb)
    TriggerServerEvent('whellco_registration:registerVehicle', data.vehicleId, data.plate)
    cb({ ok = true })
end)

RegisterNuiCallback('transferVehicle', function(data, cb)
    TriggerServerEvent('whellco_registration:transferVehicle', data.vehicleId, data.targetId)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
