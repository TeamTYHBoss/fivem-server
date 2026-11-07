local adminOpen = false

local function openAdmin(data)
    if adminOpen then
        return
    end

    adminOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        results = data.results
    })
end

local function closeAdmin()
    if not adminOpen then
        return
    end

    adminOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_admin:openPanel', openAdmin)

RegisterNetEvent('whellco_admin:closePanel', closeAdmin)

RegisterNetEvent('whellco_admin:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('admin', function()
    TriggerServerEvent('whellco_admin:openPanel')
end, true)

RegisterNuiCallback('closeAdmin', function(_, cb)
    TriggerServerEvent('whellco_admin:closePanel')
    cb({ ok = true })
end)

RegisterNuiCallback('searchPlayers', function(data, cb)
    TriggerServerEvent('whellco_admin:searchPlayers', data.query)
    cb({ ok = true })
end)

RegisterNuiCallback('giveMoney', function(data, cb)
    TriggerServerEvent('whellco_admin:giveMoney', data)
    cb({ ok = true })
end)

RegisterNuiCallback('removeMoney', function(data, cb)
    TriggerServerEvent('whellco_admin:removeMoney', data)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
