local restoreMenuOpen = false

local function openRestoreMenu(data)
    if restoreMenuOpen then
        return
    end

    restoreMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        types = data.types,
        logs = data.logs
    })
end

local function closeRestoreMenu()
    if not restoreMenuOpen then
        return
    end

    restoreMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_restore:openMenu', openRestoreMenu)

RegisterNetEvent('whellco_restore:closeMenu', closeRestoreMenu)

RegisterNetEvent('whellco_restore:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('restore', function()
    TriggerServerEvent('whellco_restore:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_restore:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('requestRestore', function(data, cb)
    TriggerServerEvent('whellco_restore:requestRestore', data.restoreType, data.fileName)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
