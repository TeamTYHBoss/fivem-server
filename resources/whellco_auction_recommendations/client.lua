local recommendationMenuOpen = false

local function openRecommendationMenu(data)
    if recommendationMenuOpen then
        return
    end

    recommendationMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        recommendations = data.recommendations,
        types = data.types
    })
end

local function closeRecommendationMenu()
    if not recommendationMenuOpen then
        return
    end

    recommendationMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_auction_recommendations:openMenu', openRecommendationMenu)

RegisterNetEvent('whellco_auction_recommendations:closeMenu', closeRecommendationMenu)

RegisterNetEvent('whellco_auction_recommendations:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('auctionrecommendations', function()
    TriggerServerEvent('whellco_auction_recommendations:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_auction_recommendations:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('generateRecommendations', function(_, cb)
    TriggerServerEvent('whellco_auction_recommendations:generateRecommendations')
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
