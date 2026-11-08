local QBCore = exports['qb-core']:GetCoreObject()

local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

local function sendMenu(source, filter)
    filter = tostring(filter or 'all')

    if not Config.ExportFilters[filter] then
        filter = 'all'
    end

    local exports

    if filter == 'all' then
        exports = MySQL.query.await(
            [[
                SELECT id, auction_id, plate, seller_id, buyer_id, final_price, status, exported_at
                FROM whellco_auction_exports
                ORDER BY exported_at DESC
                LIMIT ?
            ]],
            { Config.MaxExportResults }
        ) or {}
    else
        exports = MySQL.query.await(
            [[
                SELECT id, auction_id, plate, seller_id, buyer_id, final_price, status, exported_at
                FROM whellco_auction_exports
                WHERE status = ?
                ORDER BY exported_at DESC
                LIMIT ?
            ]],
            { filter, Config.MaxExportResults }
        ) or {}
    end

    TriggerClientEvent('whellco_auction_exports:openMenu', source, {
        exports = exports,
        filters = Config.ExportFilters
    })
end

RegisterNetEvent('whellco_auction_exports:openMenu', function()
    if not QBCore.Functions.HasPermission(source, 'admin') then
        return
    end

    sendMenu(source, 'all')
end)

RegisterNetEvent('whellco_auction_exports:closeMenu', function()
    TriggerClientEvent('whellco_auction_exports:closeMenu', source)
end)

RegisterNetEvent('whellco_auction_exports:filterExports', function(filter)
    if not QBCore.Functions.HasPermission(source, 'admin') then
        return
    end

    sendMenu(source, filter)
end)

RegisterNetEvent('whellco_auction_exports:exportAuction', function(auctionId, plate, sellerId, buyerId, finalPrice, status)
    local source = source
    local Player = getQbPlayer(source)

    if not Player or not QBCore.Functions.HasPermission(source, 'admin') then
        return
    end

    plate = tostring(plate or ''):upper():sub(1, 8)
    status = tostring(status or 'sold')

    if not Config.ExportFilters[status] then
        status = 'sold'
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_auction_exports
                (auction_id, plate, seller_id, buyer_id, final_price, status)
            VALUES (?, ?, ?, ?, ?, ?)
        ]],
        { auctionId, plate, sellerId, buyerId, finalPrice or 0, status }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Auction exported.', 'success')

    sendMenu(source, 'all')
end)