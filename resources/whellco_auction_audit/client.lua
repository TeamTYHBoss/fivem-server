local auditMenuOpen = false

local function openAuditMenu(data)
    if auditMenuOpen then
        return
    end

    auditMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        logs = data.logs,
        actions = data.actions
    })
end

local function closeAuditMenu()
    if not auditMenuOpen then
        return
    end

    auditMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_auction_audit:openMenu', openAuditMenu)

RegisterNetEvent('whellco_auction_audit:closeMenu', closeAuditMenu)

RegisterNetEvent('whellco_auction_audit:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('auctionaudit', function()
    TriggerServerEvent('whellco_auction_audit:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_auction_audit:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('recordAudit', function(data, cb)
    TriggerServerEvent('whellco_auction_audit:recordAudit', data.auctionId, data.action, data.details)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
