local exportMenuOpen = false

local function openExportMenu(data)
    if exportMenuOpen then
        return
    end

    exportMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        exports = data.exports,
        filters = data.filters
    })
end

local function closeExportMenu()
    if not exportMenuOpen then
        return
    end

    exportMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_auction_exports:openMenu', openExportMenu)

RegisterNetEvent('whellco_auction_exports:closeMenu', closeExportMenu)

RegisterNetEvent('whellco_auction_exports:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('auctionexports', function()
    TriggerServerEvent('whellco_auction_exports:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_auction_exports:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('filterExports', function(data, cb)
    TriggerServerEvent('whellco_auction_exports:filterExports', data.filter)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
