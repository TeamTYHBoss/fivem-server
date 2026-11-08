local backupMenuOpen = false

local function openBackupMenu(data)
    if backupMenuOpen then
        return
    end

    backupMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        types = data.types,
        logs = data.logs
    })
end

local function closeBackupMenu()
    if not backupMenuOpen then
        return
    end

    backupMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_backup:openMenu', openBackupMenu)

RegisterNetEvent('whellco_backup:closeMenu', closeBackupMenu)

RegisterNetEvent('whellco_backup:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('backup', function()
    TriggerServerEvent('whellco_backup:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_backup:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('createBackup', function(data, cb)
    TriggerServerEvent('whellco_backup:createBackup', data.backupType)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
