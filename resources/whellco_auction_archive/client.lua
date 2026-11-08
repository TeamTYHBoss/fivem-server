local archiveMenuOpen = false

local function openArchiveMenu(data)
    if archiveMenuOpen then
        return
    end

    archiveMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        auctions = data.auctions,
        filters = data.filters
    })
end

local function closeArchiveMenu()
    if not archiveMenuOpen then
        return
    end

    archiveMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_auction_archive:openMenu', openArchiveMenu)

RegisterNetEvent('whellco_auction_archive:closeMenu', closeArchiveMenu)

RegisterNetEvent('whellco_auction_archive:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('auctionarchive', function()
    TriggerServerEvent('whellco_auction_archive:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_auction_archive:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('filterArchive', function(data, cb)
    TriggerServerEvent('whellco_auction_archive:filterArchive', data.filter)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
