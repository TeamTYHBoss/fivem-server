local historyMenuOpen = false

local function openHistoryMenu(data)
    if historyMenuOpen then
        return
    end

    historyMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        auctions = data.auctions,
        bids = data.bids
    })
end

local function closeHistoryMenu()
    if not historyMenuOpen then
        return
    end

    historyMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_auction_history:openMenu', openHistoryMenu)

RegisterNetEvent('whellco_auction_history:closeMenu', closeHistoryMenu)

RegisterNetEvent('whellco_auction_history:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('auctionhistory', function()
    TriggerServerEvent('whellco_auction_history:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_auction_history:closeMenu')
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
