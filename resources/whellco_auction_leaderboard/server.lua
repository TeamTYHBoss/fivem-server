local function sendMenu(source)
    local bidders = MySQL.query.await(
        [[
            SELECT player_id, total_bids, total_spent, auctions_won
            FROM whellco_auction_leaderboard
            ORDER BY total_spent DESC
            LIMIT ?
        ]],
        { Config.LeaderboardSize }
    ) or {}

    local sellers = MySQL.query.await(
        [[
            SELECT player_id, auctions_sold, total_spent
            FROM whellco_auction_leaderboard
            ORDER BY auctions_sold DESC
            LIMIT ?
        ]],
        { Config.LeaderboardSize }
    ) or {}

    TriggerClientEvent('whellco_auction_leaderboard:openMenu', source, {
        bidders = bidders,
        sellers = sellers
    })
end

RegisterNetEvent('whellco_auction_leaderboard:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_auction_leaderboard:closeMenu', function()
    TriggerClientEvent('whellco_auction_leaderboard:closeMenu', source)
end)

RegisterNetEvent('whellco_auction_leaderboard:updateStats', function(playerId, totalBids, totalSpent, auctionsWon, auctionsSold)
    local source = source

    totalBids = tonumber(totalBids) or 0
    totalSpent = tonumber(totalSpent) or 0
    auctionsWon = tonumber(auctionsWon) or 0
    auctionsSold = tonumber(auctionsSold) or 0

    local existing = MySQL.single.await(
        [[
            SELECT id
            FROM whellco_auction_leaderboard
            WHERE player_id = ?
            LIMIT 1
        ]],
        { playerId }
    )

    if existing then
        MySQL.query.await(
            [[
                UPDATE whellco_auction_leaderboard
                SET total_bids = ?, total_spent = ?, auctions_won = ?, auctions_sold = ?
                WHERE id = ?
            ]],
            { totalBids, totalSpent, auctionsWon, auctionsSold, existing.id }
        )
    else
        MySQL.insert.await(
            [[
                INSERT INTO whellco_auction_leaderboard
                    (player_id, total_bids, total_spent, auctions_won, auctions_sold)
                VALUES (?, ?, ?, ?, ?)
            ]],
            { playerId, totalBids, totalSpent, auctionsWon, auctionsSold }
        )
    end

    TriggerClientEvent('whellco_auction_leaderboard:notify', source, 'Leaderboard updated.')

    sendMenu(source)
end)
