local categoryMenuOpen = false

local function openCategoryMenu(data)
    if categoryMenuOpen then
        return
    end

    categoryMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        categories = data.categories,
        auctions = data.auctions
    })
end

local function closeCategoryMenu()
    if not categoryMenuOpen then
        return
    end

    categoryMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_auction_categories:openMenu', openCategoryMenu)

RegisterNetEvent('whellco_auction_categories:closeMenu', closeCategoryMenu)

RegisterNetEvent('whellco_auction_categories:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('auctioncategories', function()
    TriggerServerEvent('whellco_auction_categories:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_auction_categories:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('setCategory', function(data, cb)
    TriggerServerEvent('whellco_auction_categories:setCategory', data.auctionId, data.categoryId)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
