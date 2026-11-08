local dashboardMenuOpen = false

local function openDashboardMenu(data)
    if dashboardMenuOpen then
        return
    end

    dashboardMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        insights = data.insights,
        filters = data.filters
    })
end

local function closeDashboardMenu()
    if not dashboardMenuOpen then
        return
    end

    dashboardMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_auction_insights_dashboard:openMenu', openDashboardMenu)

RegisterNetEvent('whellco_auction_insights_dashboard:closeMenu', closeDashboardMenu)

RegisterNetEvent('whellco_auction_insights_dashboard:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('auctiondashboard', function()
    TriggerServerEvent('whellco_auction_insights_dashboard:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_auction_insights_dashboard:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('filterDashboard', function(data, cb)
    TriggerServerEvent('whellco_auction_insights_dashboard:filterDashboard', data.filter)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
