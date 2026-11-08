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
            SELECT id, plate, seller_id, starting_bid, current_bid, current_bidder_id, ends_at, status
            FROM whellco_plate_auctions
            WHERE status = 'active' AND ends_at > NOW()
            ORDER BY ends_at ASC
        ]]
    ) or {}

    TriggerClientEvent('whellco_plate_auction:openMenu', source, {
        auctions = auctions
    })
end

RegisterNetEvent('whellco_plate_auction:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_plate_auction:closeMenu', function()
    TriggerClientEvent('whellco_plate_auction:closeMenu', source)
end)

RegisterNetEvent('whellco_plate_auction:placeBid', function(auctionId, bidAmount)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    bidAmount = tonumber(bidAmount) or 0

    if bidAmount <= 0 then
        return
    end

    local auction = MySQL.single.await(
        [[
            SELECT id, plate, seller_id, starting_bid, current_bid, current_bidder_id, ends_at, status
            FROM whellco_plate_auctions
            WHERE id = ? AND status = 'active' AND ends_at > NOW()
            LIMIT 1
        ]],
        { auctionId }
    )

    if not auction then
        return
    end

    if auction.seller_id == identifier then
        return
    end

    local minimumBid = auction.current_bid > 0
        and auction.current_bid + Config.MinBidIncrement
        or auction.starting_bid

    if bidAmount < minimumBid then
        TriggerClientEvent('whellco_plate_auction:notify', source, ('Minimum bid is £%s.'):format(minimumBid))
        return
    end

    MySQL.query.await(
        [[
            UPDATE whellco_plate_auctions
            SET current_bid = ?, current_bidder_id = ?
            WHERE id = ?
        ]],
        { bidAmount, identifier, auction.id }
    )

    MySQL.insert.await(
        [[
            INSERT INTO whellco_plate_bids
                (auction_id, bidder_id, bid_amount)
            VALUES (?, ?, ?)
        ]],
        { auction.id, identifier, bidAmount }
    )

    TriggerClientEvent('whellco_plate_auction:notify', source, ('Bid placed on plate %s for £%s.'):format(auction.plate, bidAmount))

    sendMenu(source)
end)
