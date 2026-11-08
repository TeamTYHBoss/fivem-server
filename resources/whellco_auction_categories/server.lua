local function sendMenu(source)
    local auctions = MySQL.query.await(
        [[
            SELECT id, auction_id, category_id, created_at
            FROM whellco_auction_categories
            ORDER BY created_at DESC
            LIMIT ?
        ]],
        { Config.MaxCategories }
    ) or {}

    TriggerClientEvent('whellco_auction_categories:openMenu', source, {
        categories = Config.AuctionCategories,
        auctions = auctions
    })
end

RegisterNetEvent('whellco_auction_categories:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_auction_categories:closeMenu', function()
    TriggerClientEvent('whellco_auction_categories:closeMenu', source)
end)

RegisterNetEvent('whellco_auction_categories:setCategory', function(auctionId, categoryId)
    local source = source

    categoryId = tonumber(categoryId) or 0

    local validCategory = false

    for _, category in ipairs(Config.AuctionCategories) do
        if category.id == categoryId then
            validCategory = true
            break
        end
    end

    if not validCategory then
        return
    end

    local existing = MySQL.single.await(
        [[
            SELECT id
            FROM whellco_auction_categories
            WHERE auction_id = ?
            LIMIT 1
        ]],
        { auctionId }
    )

    if existing then
        MySQL.query.await(
            [[
                UPDATE whellco_auction_categories
                SET category_id = ?
                WHERE id = ?
            ]],
            { categoryId, existing.id }
        )
    else
        MySQL.insert.await(
            [[
                INSERT INTO whellco_auction_categories
                    (auction_id, category_id)
                VALUES (?, ?)
            ]],
            { auctionId, categoryId }
        )
    end

    TriggerClientEvent('whellco_auction_categories:notify', source, 'Auction category updated.')

    sendMenu(source)
end)
