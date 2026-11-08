local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_player_reports:open', function()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open' })
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    cb('ok')
end)

RegisterNUICallback('submit', function(data, cb)
    TriggerServerEvent('whellco_player_reports:submit', data)
    cb('ok')
end)

RegisterNetEvent('whellco_player_reports:new', function(report)
    if not report then
        return
    end

    QBCore.Functions.Notify(
        ('New report: %s - %s'):format(report.typeLabel, report.title),
        'error',
        10000
    )
end)

RegisterCommand('reportinfo', function()
    QBCore.Functions.Notify('Use /report to report cheating, harassment, bugs, or other issues.', 'primary')
end, false)