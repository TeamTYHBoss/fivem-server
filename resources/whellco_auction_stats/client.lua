local statsMenuOpen = false

local function openStatsMenu(data)
    if statsMenuOpen then
        return
    end

    statsMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        stats = data.stats
    })
end

local function closeStatsMenu()
    if not statsMenuOpen then
        return
    end

    statsMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_auction_stats:openMenu', openStatsMenu)

RegisterNetEvent('whellco_auction_stats:closeMenu', closeStatsMenu)

RegisterNetEvent('whellco_auction_stats:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('auctionstats', function()
    TriggerServerEvent('whellco_auction_stats:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_auction_stats:closeMenu')
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
