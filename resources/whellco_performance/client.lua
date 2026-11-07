local performanceMenuOpen = false

local function openPerformanceMenu(data)
    if performanceMenuOpen then
        return
    end

    performanceMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        metrics = data.metrics,
        loadOrder = data.loadOrder
    })
end

local function closePerformanceMenu()
    if not performanceMenuOpen then
        return
    end

    performanceMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_performance:openMenu', openPerformanceMenu)

RegisterNetEvent('whellco_performance:closeMenu', closePerformanceMenu)

RegisterNetEvent('whellco_performance:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('performance', function()
    TriggerServerEvent('whellco_performance:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_performance:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('optimizeResource', function(data, cb)
    TriggerServerEvent('whellco_performance:optimizeResource', data.resource)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
