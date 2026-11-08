local tagMenuOpen = false

local function openTagMenu(data)
    if tagMenuOpen then
        return
    end

    tagMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        tags = data.tags
    })
end

local function closeTagMenu()
    if not tagMenuOpen then
        return
    end

    tagMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_auction_tags:openMenu', openTagMenu)

RegisterNetEvent('whellco_auction_tags:closeMenu', closeTagMenu)

RegisterNetEvent('whellco_auction_tags:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('auctiontags', function()
    TriggerServerEvent('whellco_auction_tags:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_auction_tags:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('addTag', function(data, cb)
    TriggerServerEvent('whellco_auction_tags:addTag', data.auctionId, data.tag)
    cb({ ok = true })
end)

RegisterNuiCallback('removeTag', function(data, cb)
    TriggerServerEvent('whellco_auction_tags:removeTag', data.tagId)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
