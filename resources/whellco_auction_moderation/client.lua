local moderationMenuOpen = false

local function openModerationMenu(data)
    if moderationMenuOpen then
        return
    end

    moderationMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        actions = data.actions,
        logs = data.logs
    })
end

local function closeModerationMenu()
    if not moderationMenuOpen then
        return
    end

    moderationMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_auction_moderation:openMenu', openModerationMenu)

RegisterNetEvent('whellco_auction_moderation:closeMenu', closeModerationMenu)

RegisterNetEvent('whellco_auction_moderation:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('auctionmoderation', function()
    TriggerServerEvent('whellco_auction_moderation:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_auction_moderation:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('moderateAuction', function(data, cb)
    TriggerServerEvent('whellco_auction_moderation:moderateAuction', data.auctionId, data.action, data.note)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
