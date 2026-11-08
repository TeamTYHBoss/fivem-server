local favoritesMenuOpen = false

local function openFavoritesMenu(data)
    if favoritesMenuOpen then
        return
    end

    favoritesMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        favorites = data.favorites
    })
end

local function closeFavoritesMenu()
    if not favoritesMenuOpen then
        return
    end

    favoritesMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_auction_favorites:openMenu', openFavoritesMenu)

RegisterNetEvent('whellco_auction_favorites:closeMenu', closeFavoritesMenu)

RegisterNetEvent('whellco_auction_favorites:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('auctionfavorites', function()
    TriggerServerEvent('whellco_auction_favorites:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_auction_favorites:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('favoriteAuction', function(data, cb)
    TriggerServerEvent('whellco_auction_favorites:favoriteAuction', data.auctionId, data.plate)
    cb({ ok = true })
end)

RegisterNuiCallback('unfavoriteAuction', function(data, cb)
    TriggerServerEvent('whellco_auction_favorites:unfavoriteAuction', data.auctionId)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
