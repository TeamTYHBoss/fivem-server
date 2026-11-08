local analyticsMenuOpen = false

local function openAnalyticsMenu(data)
    if analyticsMenuOpen then
        return
    end

    analyticsMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        analytics = data.analytics
    })
end

local function closeAnalyticsMenu()
    if not analyticsMenuOpen then
        return
    end

    analyticsMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_auction_analytics:openMenu', openAnalyticsMenu)

RegisterNetEvent('whellco_auction_analytics:closeMenu', closeAnalyticsMenu)

RegisterNetEvent('whellco_auction_analytics:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('auctionanalytics', function()
    TriggerServerEvent('whellco_auction_analytics:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_auction_analytics:closeMenu')
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
