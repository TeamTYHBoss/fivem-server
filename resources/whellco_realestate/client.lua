local realEstateMenuOpen = false

local function openRealEstateMenu(data)
    if realEstateMenuOpen then
        return
    end

    realEstateMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        properties = data.properties,
        purchases = data.purchases,
        rentals = data.rentals
    })
end

local function closeRealEstateMenu()
    if not realEstateMenuOpen then
        return
    end

    realEstateMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_realestate:openMenu', openRealEstateMenu)

RegisterNetEvent('whellco_realestate:closeMenu', closeRealEstateMenu)

RegisterNetEvent('whellco_realestate:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('realestate', function()
    TriggerServerEvent('whellco_realestate:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_realestate:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('buyProperty', function(data, cb)
    TriggerServerEvent('whellco_realestate:buyProperty', data.propertyId)
    cb({ ok = true })
end)

RegisterNuiCallback('rentProperty', function(data, cb)
    TriggerServerEvent('whellco_realestate:rentProperty', data.propertyId)
    cb({ ok = true })
end)

RegisterNuiCallback('sellProperty', function(data, cb)
    TriggerServerEvent('whellco_realestate:sellProperty', data.propertyId)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
