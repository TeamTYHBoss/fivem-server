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

    local favorites = MySQL.query.await(
        [[
            SELECT id, player_id, auction_id, plate, created_at
            FROM whellco_auction_favorites
            WHERE player_id = ?
            ORDER BY created_at DESC
            LIMIT ?
        ]],
        { identifier, Config.MaxFavorites }
    ) or {}

    TriggerClientEvent('whellco_auction_favorites:openMenu', source, {
        favorites = favorites
    })
end

RegisterNetEvent('whellco_auction_favorites:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_auction_favorites:closeMenu', function()
    TriggerClientEvent('whellco_auction_favorites:closeMenu', source)
end)

RegisterNetEvent('whellco_auction_favorites:favoriteAuction', function(auctionId, plate)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local existing = MySQL.single.await(
        [[
            SELECT id
            FROM whellco_auction_favorites
            WHERE player_id = ? AND auction_id = ?
            LIMIT 1
        ]],
        { identifier, auctionId }
    )

    if existing then
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_auction_favorites
                (player_id, auction_id, plate)
            VALUES (?, ?, ?)
        ]],
        { identifier, auctionId, plate }
    )

    TriggerClientEvent('whellco_auction_favorites:notify', source, ('Added auction for plate %s to favorites.'):format(plate))

    sendMenu(source)
end)

RegisterNetEvent('whellco_auction_favorites:unfavoriteAuction', function(auctionId)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    MySQL.query.await(
        [[
            DELETE FROM whellco_auction_favorites
            WHERE player_id = ? AND auction_id = ?
        ]],
        { identifier, auctionId }
    )

    TriggerClientEvent('whellco_auction_favorites:notify', source, 'Auction removed from favorites.')

    sendMenu(source)
end)
