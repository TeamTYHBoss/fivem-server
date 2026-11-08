local searchMenuOpen = false

local function openSearchMenu(data)
    if searchMenuOpen then
        return
    end

    searchMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        results = data.results,
        filters = data.filters
    })
end

local function closeSearchMenu()
    if not searchMenuOpen then
        return
    end

    searchMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_auction_search:openMenu', openSearchMenu)

RegisterNetEvent('whellco_auction_search:closeMenu', closeSearchMenu)

RegisterNetEvent('whellco_auction_search:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('auctionsearch', function()
    TriggerServerEvent('whellco_auction_search:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_auction_search:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('searchAuctions', function(data, cb)
    TriggerServerEvent('whellco_auction_search:searchAuctions', data.searchQuery, data.searchFilter)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
