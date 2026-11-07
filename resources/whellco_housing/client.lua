local housingOpen = false
local ownedVehicle = nil

local function openHousing(data)
    if housingOpen then
        return
    end

    housingOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        properties = data.properties,
        furniture = data.furniture
    })
end

local function closeHousing()
    if not housingOpen then
        return
    end

    housingOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_housing:openMenu', openHousing)

RegisterNetEvent('whellco_housing:closeMenu', closeHousing)

RegisterNetEvent('whellco_housing:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterNetEvent('whellco_housing:enterProperty', function(data)
    SetEntityCoords(PlayerPedId(), data.coords.x, data.coords.y, data.coords.z, false, false, false, false)
end)

RegisterNetEvent('whellco_housing:exitProperty', function(data)
    SetEntityCoords(PlayerPedId(), data.coords.x, data.coords.y, data.coords.z, false, false, false, false)
end)

RegisterCommand('housing', function()
    TriggerServerEvent('whellco_housing:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_housing:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('buyProperty', function(data, cb)
    TriggerServerEvent('whellco_housing:buyProperty', data.propertyId)
    cb({ ok = true })
end)

RegisterNuiCallback('enterProperty', function(data, cb)
    TriggerServerEvent('whellco_housing:enterProperty', data.propertyId)
    cb({ ok = true })
end)

RegisterNuiCallback('exitProperty', function(data, cb)
    TriggerServerEvent('whellco_housing:exitProperty', data.propertyId)
    cb({ ok = true })
end)

RegisterNuiCallback('placeFurniture', function(data, cb)
    TriggerServerEvent('whellco_housing:placeFurniture', data)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
