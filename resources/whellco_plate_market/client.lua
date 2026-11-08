local marketMenuOpen = false

local function openMarketMenu(data)
    if marketMenuOpen then
        return
    end

    marketMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        listings = data.listings
    })
end

local function closeMarketMenu()
    if not marketMenuOpen then
        return
    end

    marketMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_plate_market:openMenu', openMarketMenu)

RegisterNetEvent('whellco_plate_market:closeMenu', closeMarketMenu)

RegisterNetEvent('whellco_plate_market:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('platemarket', function()
    TriggerServerEvent('whellco_plate_market:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_plate_market:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('buyPlate', function(data, cb)
    TriggerServerEvent('whellco_plate_market:buyPlate', data.listingId)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
