local function sendMenu(source)
    local stats = MySQL.query.await(
        [[
            SELECT id, auction_id, plate, total_bids, highest_bid, final_bid, winner_id, created_at
            FROM whellco_auction_stats
            ORDER BY highest_bid DESC
            LIMIT ?
        ]],
        { Config.MaxStatsEntries }
    ) or {}

    TriggerClientEvent('whellco_auction_stats:openMenu', source, {
        stats = stats
    })
end

RegisterNetEvent('whellco_auction_stats:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_auction_stats:closeMenu', function()
    TriggerClientEvent('whellco_auction_stats:closeMenu', source)
end)

RegisterNetEvent('whellco_auction_stats:updateStats', function(auctionId, plate, totalBids, highestBid, finalBid, winnerId)
    local source = source

    totalBids = tonumber(totalBids) or 0
    highestBid = tonumber(highestBid) or 0
    finalBid = tonumber(finalBid) or 0

    local existing = MySQL.single.await(
        [[
            SELECT id
            FROM whellco_auction_stats
            WHERE auction_id = ?
            LIMIT 1
        ]],
        { auctionId }
    )

    if existing then
        MySQL.query.await(
            [[
                UPDATE whellco_auction_stats
                SET total_bids = ?, highest_bid = ?, final_bid = ?, winner_id = ?
                WHERE id = ?
            ]],
            { totalBids, highestBid, finalBid, winnerId, existing.id }
        )
    else
        MySQL.insert.await(
            [[
                INSERT INTO whellco_auction_stats
                    (auction_id, plate, total_bids, highest_bid, final_bid, winner_id)
                VALUES (?, ?, ?, ?, ?, ?)
            ]],
            { auctionId, plate, totalBids, highestBid, finalBid, winnerId }
        )
    end

    TriggerClientEvent('whellco_auction_stats:notify', source, 'Auction stats updated.')

    sendMenu(source)
end)
