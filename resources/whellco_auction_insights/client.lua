local insightsMenuOpen = false

local function openInsightsMenu(data)
    if insightsMenuOpen then
        return
    end

    insightsMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        insights = data.insights,
        categories = data.categories
    })
end

local function closeInsightsMenu()
    if not insightsMenuOpen then
        return
    end

    insightsMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_auction_insights:openMenu', openInsightsMenu)

RegisterNetEvent('whellco_auction_insights:closeMenu', closeInsightsMenu)

RegisterNetEvent('whellco_auction_insights:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('auctioninsights', function()
    TriggerServerEvent('whellco_auction_insights:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_auction_insights:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('addInsight', function(data, cb)
    TriggerServerEvent('whellco_auction_insights:addInsight', data.auctionId, data.category, data.insight, data.score)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
