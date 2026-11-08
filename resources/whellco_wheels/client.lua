local wheelMenuOpen = false

local function openWheelMenu(data)
    if wheelMenuOpen then
        return
    end

    wheelMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        vehicles = data.vehicles,
        wheels = data.wheels,
        wheelTypes = data.wheelTypes,
        wheelColors = data.wheelColors
    })
end

local function closeWheelMenu()
    if not wheelMenuOpen then
        return
    end

    wheelMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_wheels:openMenu', openWheelMenu)

RegisterNetEvent('whellco_wheels:closeMenu', closeWheelMenu)

RegisterNetEvent('whellco_wheels:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('wheels', function()
    TriggerServerEvent('whellco_wheels:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_wheels:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('applyWheels', function(data, cb)
    TriggerServerEvent('whellco_wheels:applyWheels', data.vehicleId, data.wheelType, data.wheelColor)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
