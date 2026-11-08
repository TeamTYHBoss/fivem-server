local leaderboardMenuOpen = false

local function openLeaderboardMenu(data)
    if leaderboardMenuOpen then
        return
    end

    leaderboardMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        bidders = data.bidders,
        sellers = data.sellers
    })
end

local function closeLeaderboardMenu()
    if not leaderboardMenuOpen then
        return
    end

    leaderboardMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_auction_leaderboard:openMenu', openLeaderboardMenu)

RegisterNetEvent('whellco_auction_leaderboard:closeMenu', closeLeaderboardMenu)

RegisterNetEvent('whellco_auction_leaderboard:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('auctionleaderboard', function()
    TriggerServerEvent('whellco_auction_leaderboard:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_auction_leaderboard:closeMenu')
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
