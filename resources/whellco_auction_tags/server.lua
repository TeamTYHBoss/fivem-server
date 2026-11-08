local function sendMenu(source)
    local tags = MySQL.query.await(
        [[
            SELECT id, auction_id, tag, created_at
            FROM whellco_auction_tags
            ORDER BY created_at DESC
            LIMIT 50
        ]]
    ) or {}

    TriggerClientEvent('whellco_auction_tags:openMenu', source, {
        tags = tags
    })
end

RegisterNetEvent('whellco_auction_tags:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_auction_tags:closeMenu', function()
    TriggerClientEvent('whellco_auction_tags:closeMenu', source)
end)

RegisterNetEvent('whellco_auction_tags:addTag', function(auctionId, tag)
    local source = source

    tag = tostring(tag or ''):gsub('^%s*(.-)%s*$', '%1')

    if #tag == 0 or #tag > Config.MaxTagLength then
        TriggerClientEvent('whellco_auction_tags:notify', source, 'Invalid tag length.')
        return
    end

    if not tag:match(Config.AllowedTagPattern) then
        TriggerClientEvent('whellco_auction_tags:notify', source, 'Invalid tag characters.')
        return
    end

    local count = MySQL.scalar.await(
        [[
            SELECT COUNT(*)
            FROM whellco_auction_tags
            WHERE auction_id = ?
        ]],
        { auctionId }
    ) or 0

    if count >= Config.MaxTagsPerAuction then
        TriggerClientEvent('whellco_auction_tags:notify', source, 'Tag limit reached.')
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_auction_tags
                (auction_id, tag)
            VALUES (?, ?)
        ]],
        { auctionId, tag }
    )

    TriggerClientEvent('whellco_auction_tags:notify', source, ('Tag added: %s'):format(tag))

    sendMenu(source)
end)

RegisterNetEvent('whellco_auction_tags:removeTag', function(tagId)
    local source = source

    MySQL.query.await(
        [[
            DELETE FROM whellco_auction_tags
            WHERE id = ?
        ]],
        { tagId }
    )

    TriggerClientEvent('whellco_auction_tags:notify', source, 'Tag removed.')

    sendMenu(source)
end)
