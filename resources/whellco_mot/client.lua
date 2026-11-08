local motMenuOpen = false

local function openMotMenu(data)
    if motMenuOpen then
        return
    end

    motMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        vehicles = data.vehicles,
        certificates = data.certificates,
        failures = data.failures
    })
end

local function closeMotMenu()
    if not motMenuOpen then
        return
    end

    motMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_mot:openMenu', openMotMenu)

RegisterNetEvent('whellco_mot:closeMenu', closeMotMenu)

RegisterNetEvent('whellco_mot:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('mot', function()
    TriggerServerEvent('whellco_mot:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_mot:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('bookMot', function(data, cb)
    TriggerServerEvent('whellco_mot:bookMot', data.vehicleId)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
