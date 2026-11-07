local securityMenuOpen = false

local function openSecurityMenu(data)
    if securityMenuOpen then
        return
    end

    securityMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        rules = data.rules,
        events = data.events
    })
end

local function closeSecurityMenu()
    if not securityMenuOpen then
        return
    end

    securityMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_security:openMenu', openSecurityMenu)

RegisterNetEvent('whellco_security:closeMenu', closeSecurityMenu)

RegisterNetEvent('whellco_security:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('security', function()
    TriggerServerEvent('whellco_security:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_security:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('validateInput', function(data, cb)
    TriggerServerEvent('whellco_security:validateInput', data.input)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
