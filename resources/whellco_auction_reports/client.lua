local reportMenuOpen = false

local function openReportMenu(data)
    if reportMenuOpen then
        return
    end

    reportMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        reports = data.reports,
        reasons = data.reasons
    })
end

local function closeReportMenu()
    if not reportMenuOpen then
        return
    end

    reportMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_auction_reports:openMenu', openReportMenu)

RegisterNetEvent('whellco_auction_reports:closeMenu', closeReportMenu)

RegisterNetEvent('whellco_auction_reports:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('auctionreports', function()
    TriggerServerEvent('whellco_auction_reports:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_auction_reports:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('submitReport', function(data, cb)
    TriggerServerEvent('whellco_auction_reports:submitReport', data.auctionId, data.reason, data.details)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
