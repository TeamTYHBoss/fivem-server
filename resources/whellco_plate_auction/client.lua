local auctionMenuOpen = false

local function openAuctionMenu(data)
    if auctionMenuOpen then
        return
    end

    auctionMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        auctions = data.auctions
    })
end

local function closeAuctionMenu()
    if not auctionMenuOpen then
        return
    end

    auctionMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_plate_auction:openMenu', openAuctionMenu)

RegisterNetEvent('whellco_plate_auction:closeMenu', closeAuctionMenu)

RegisterNetEvent('whellco_plate_auction:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('plateauction', function()
    TriggerServerEvent('whellco_plate_auction:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_plate_auction:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('placeBid', function(data, cb)
    TriggerServerEvent('whellco_plate_auction:placeBid', data.auctionId, data.bidAmount)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
