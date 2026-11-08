local wantedMenuOpen = false

local function openWantedMenu(data)
    if wantedMenuOpen then
        return
    end

    wantedMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        wanted = data.wanted
    })
end

local function closeWantedMenu()
    if not wantedMenuOpen then
        return
    end

    wantedMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_wanted:openMenu', openWantedMenu)

RegisterNetEvent('whellco_wanted:closeMenu', closeWantedMenu)

RegisterNetEvent('whellco_wanted:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('wanted', function()
    TriggerServerEvent('whellco_wanted:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_wanted:closeMenu')
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
