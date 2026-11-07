local adminMenuOpen = false

local function openAdminMenu(data)
    if adminMenuOpen then
        return
    end

    adminMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        players = data.players,
        bans = data.bans,
        actions = data.actions
    })
end

local function closeAdminMenu()
    if not adminMenuOpen then
        return
    end

    adminMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_admin:openMenu', openAdminMenu)

RegisterNetEvent('whellco_admin:closeMenu', closeAdminMenu)

RegisterNetEvent('whellco_admin:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('admin', function()
    TriggerServerEvent('whellco_admin:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_admin:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('kickPlayer', function(data, cb)
    TriggerServerEvent('whellco_admin:kickPlayer', data.targetId, data.reason)
    cb({ ok = true })
end)

RegisterNuiCallback('banPlayer', function(data, cb)
    TriggerServerEvent('whellco_admin:banPlayer', data.targetId, data.reason)
    cb({ ok = true })
end)

RegisterNuiCallback('unbanPlayer', function(data, cb)
    TriggerServerEvent('whellco_admin:unbanPlayer', data.banId)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
