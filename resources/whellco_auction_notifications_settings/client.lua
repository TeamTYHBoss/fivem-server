local settingsMenuOpen = false

local function openSettingsMenu(data)
    if settingsMenuOpen then
        return
    end

    settingsMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        settings = data.settings,
        channels = data.channels,
        preferences = data.preferences
    })
end

local function closeSettingsMenu()
    if not settingsMenuOpen then
        return
    end

    settingsMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_auction_notifications_settings:openMenu', openSettingsMenu)

RegisterNetEvent('whellco_auction_notifications_settings:closeMenu', closeSettingsMenu)

RegisterNetEvent('whellco_auction_notifications_settings:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('auctionalertsettings', function()
    TriggerServerEvent('whellco_auction_notifications_settings:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_auction_notifications_settings:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('saveSettings', function(data, cb)
    TriggerServerEvent('whellco_auction_notifications_settings:saveSettings', data)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
