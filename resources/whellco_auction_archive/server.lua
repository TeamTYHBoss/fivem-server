local function sendMenu(source, filter)
    filter = tostring(filter or 'all')

    if not Config.ArchiveFilters[filter] then
        filter = 'all'
    end

    local auctions

    if filter == 'all' then
        auctions = MySQL.query.await(
            [[
                SELECT id, auction_id, plate, seller_id, buyer_id, final_price, status, archived_at
                FROM whellco_auction_archive
                ORDER BY archived_at DESC
                LIMIT ?
            ]],
            { Config.MaxArchiveResults }
        ) or {}
    else
        auctions = MySQL.query.await(
            [[
                SELECT id, auction_id, plate, seller_id, buyer_id, final_price, status, archived_at
                FROM whellco_auction_archive
                WHERE status = ?
                ORDER BY archived_at DESC
                LIMIT ?
            ]],
            { filter, Config.MaxArchiveResults }
        ) or {}
    end

    TriggerClientEvent('whellco_auction_archive:openMenu', source, {
        auctions = auctions,
        filters = Config.ArchiveFilters
    })
end

RegisterNetEvent('whellco_auction_archive:openMenu', function()
    sendMenu(source, 'all')
end)

RegisterNetEvent('whellco_auction_archive:closeMenu', function()
    TriggerClientEvent('whellco_auction_archive:closeMenu', source)
end)

RegisterNetEvent('whellco_auction_archive:filterArchive', function(filter)
    sendMenu(source, filter)
end)

RegisterNetEvent('whellco_auction_archive:archiveAuction', function(auctionId, plate, sellerId, buyerId, finalPrice, status)
    local source = source

    if not IsPlayerAceAllowed(source, 'whellco.auction.moderate') then
        return
    end

    plate = tostring(plate or ''):upper():sub(1, 8)
    status = tostring(status or 'sold')

    if not Config.ArchiveFilters[status] then
        status = 'sold'
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_auction_archive
                (auction_id, plate, seller_id, buyer_id, final_price, status)
            VALUES (?, ?, ?, ?, ?, ?)
        ]],
        { auctionId, plate, sellerId, buyerId, finalPrice or 0, status }
    )

    TriggerClientEvent('whellco_auction_archive:notify', source, 'Auction archived.')

    sendMenu(source, 'all')
end)
