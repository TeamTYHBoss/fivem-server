local QBCore = exports['qb-core']:GetCoreObject()

local dashboardOpen = false
local currentPage = 1

RegisterNetEvent('whellco_report_dashboard:open', function()
    dashboardOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open' })

    TriggerServerEvent('whellco_report_dashboard:refresh', currentPage)
end)

RegisterNetEvent('whellco_report_dashboard:refresh', function(data)
    SendNUIMessage({
        action = 'refresh',
        reports = data.reports,
        page = data.page,
        totalPages = data.totalPages,
        openCount = data.openCount
    })
end)

RegisterNetEvent('whellco_report_dashboard:newReport', function()
    SendNUIMessage({ action = 'newReport' })
    PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    QBCore.Functions.Notify('New player report received.', 'error', 10000)
end)

RegisterNUICallback('close', function(_, cb)
    dashboardOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    cb('ok')
end)

RegisterNUICallback('refresh', function(data, cb)
    currentPage = tonumber(data.page) or 1
    TriggerServerEvent('whellco_report_dashboard:refresh', currentPage)
    cb('ok')
end)

RegisterNUICallback('action', function(data, cb)
    TriggerServerEvent('whellco_report_dashboard:action', data.action, data.reportId, data.note)
    cb('ok')
end)

RegisterNetEvent('whellco_report_dashboard:goto', function(coords)
    if not coords then
        return
    end

    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, false)
    QBCore.Functions.Notify('Teleported to report location.', 'success')
end)

RegisterCommand('dashboardinfo', function()
    QBCore.Functions.Notify('Use /reportdashboard to open the staff report dashboard.', 'primary')
end, false)