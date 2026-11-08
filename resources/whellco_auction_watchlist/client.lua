local watchlistMenuOpen = false

local function openWatchlistMenu(data)
    if watchlistMenuOpen then
        return
    end

    watchlistMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        watchlist = data.watchlist
    })
end

local function closeWatchlistMenu()
    if not watchlistMenuOpen then
        return
    end

    watchlistMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_auction_watchlist:openMenu', openWatchlistMenu)

RegisterNetEvent('whellco_auction_watchlist:closeMenu', closeWatchlistMenu)

RegisterNetEvent('whellco_auction_watchlist:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('auctionwatchlist', function()
    TriggerServerEvent('whellco_auction_watchlist:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_auction_watchlist:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('watchAuction', function(data, cb)
    TriggerServerEvent('whellco_auction_watchlist:watchAuction', data.auctionId, data.plate)
    cb({ ok = true })
end)

RegisterNuiCallback('unwatchAuction', function(data, cb)
    TriggerServerEvent('whellco_auction_watchlist:unwatchAuction', data.auctionId)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
