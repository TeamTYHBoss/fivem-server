local notificationMenuOpen = false

local function openNotificationMenu(data)
    if notificationMenuOpen then
        return
    end

    notificationMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        notifications = data.notifications,
        types = data.types
    })
end

local function closeNotificationMenu()
    if not notificationMenuOpen then
        return
    end

    notificationMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_auction_notifications:openMenu', openNotificationMenu)

RegisterNetEvent('whellco_auction_notifications:closeMenu', closeNotificationMenu)

RegisterNetEvent('whellco_auction_notifications:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('auctionalerts', function()
    TriggerServerEvent('whellco_auction_notifications:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_auction_notifications:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('markRead', function(data, cb)
    TriggerServerEvent('whellco_auction_notifications:markRead', data.notificationId)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
