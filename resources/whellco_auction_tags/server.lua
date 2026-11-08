local QBCore = exports['qb-core']:GetCoreObject()

local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

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
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    sendMenu(source)
end)

RegisterNetEvent('whellco_auction_tags:closeMenu', function()
    TriggerClientEvent('whellco_auction_tags:closeMenu', source)
end)

RegisterNetEvent('whellco_auction_tags:addTag', function(auctionId, tag)
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    tag = tostring(tag or ''):gsub('^%s*(.-)%s*$', '%1')

    if #tag == 0 or #tag > Config.MaxTagLength then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid tag length.', 'error')
        return
    end

    if not tag:match(Config.AllowedTagPattern) then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid tag characters.', 'error')
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
        TriggerClientEvent('QBCore:Notify', source, 'Tag limit reached.', 'error')
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

    TriggerClientEvent('QBCore:Notify', source, ('Tag added: %s'):format(tag), 'success')

    sendMenu(source)
end)

RegisterNetEvent('whellco_auction_tags:removeTag', function(tagId)
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    MySQL.query.await(
        [[
            DELETE FROM whellco_auction_tags
            WHERE id = ?
        ]],
        { tagId }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Tag removed.', 'success')

    sendMenu(source)
end)