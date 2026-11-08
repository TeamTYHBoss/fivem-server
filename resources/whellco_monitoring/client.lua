local monitoringMenuOpen = false

local function openMonitoringMenu(data)
    if monitoringMenuOpen then
        return
    end

    monitoringMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        metrics = data.metrics,
        alerts = data.alerts
    })
end

local function closeMonitoringMenu()
    if not monitoringMenuOpen then
        return
    end

    monitoringMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_monitoring:openMenu', openMonitoringMenu)

RegisterNetEvent('whellco_monitoring:closeMenu', closeMonitoringMenu)

RegisterNetEvent('whellco_monitoring:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('monitoring', function()
    TriggerServerEvent('whellco_monitoring:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_monitoring:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('refreshMetrics', function(_, cb)
    TriggerServerEvent('whellco_monitoring:refreshMetrics')
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
