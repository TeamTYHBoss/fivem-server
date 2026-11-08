local chaseMenuOpen = false

local function openChaseMenu(data)
    if chaseMenuOpen then
        return
    end

    chaseMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        chases = data.chases
    })
end

local function closeChaseMenu()
    if not chaseMenuOpen then
        return
    end

    chaseMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_chase:openMenu', openChaseMenu)

RegisterNetEvent('whellco_chase:closeMenu', closeChaseMenu)

RegisterNetEvent('whellco_chase:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('chase', function()
    TriggerServerEvent('whellco_chase:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_chase:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('endChase', function(data, cb)
    TriggerServerEvent('whellco_chase:endChase', data.chaseId)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
