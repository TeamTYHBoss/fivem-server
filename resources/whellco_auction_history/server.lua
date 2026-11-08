local function getIdentifier(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')

    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'steam')
    end

    return identifier
end

local function sendMenu(source)
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local auctions = MySQL.query.await(
        [[
            SELECT id, auction_id, plate, seller_id, final_bid, winner_id, ended_at, created_at
            FROM whellco_auction_history
            ORDER BY created_at DESC
            LIMIT ?
        ]],
        { Config.MaxHistoryEntries }
    ) or {}

    local bids = MySQL.query.await(
        [[
            SELECT id, auction_id, bidder_id, bid_amount, created_at
            FROM whellco_bid_history
            ORDER BY created_at DESC
            LIMIT ?
        ]],
        { Config.MaxHistoryEntries }
    ) or {}

    TriggerClientEvent('whellco_auction_history:openMenu', source, {
        auctions = auctions,
        bids = bids
    })
end

RegisterNetEvent('whellco_auction_history:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_auction_history:closeMenu', function()
    TriggerClientEvent('whellco_auction_history:closeMenu', source)
end)

RegisterNetEvent('whellco_auction_history:recordAuction', function(auctionId, plate, sellerId, finalBid, winnerId)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_auction_history
                (auction_id, plate, seller_id, final_bid, winner_id, ended_at)
            VALUES (?, ?, ?, ?, ?, NOW())
        ]],
        { auctionId, plate, sellerId, finalBid or 0, winnerId }
    )

    TriggerClientEvent('whellco_auction_history:notify', source, 'Auction history recorded.')

    sendMenu(source)
end)

RegisterNetEvent('whellco_auction_history:recordBid', function(auctionId, bidderId, bidAmount)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_bid_history
                (auction_id, bidder_id, bid_amount)
            VALUES (?, ?, ?)
        ]],
        { auctionId, bidderId, bidAmount or 0 }
    )

    TriggerClientEvent('whellco_auction_history:notify', source, 'Bid history recorded.')

    sendMenu(source)
end)
