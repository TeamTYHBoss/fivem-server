local QBCore = exports['qb-core']:GetCoreObject()

local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

RegisterNetEvent('whellco_auction_favorites:openMenu', function()
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    local favorites = MySQL.query.await(
        [[
            SELECT id, auction_id, created_at
            FROM whellco_auction_favorites
            WHERE character_id = ?
            ORDER BY created_at DESC
            LIMIT 25
        ]],
        { Player.PlayerData.citizenid }
    ) or {}

    TriggerClientEvent('whellco_auction_favorites:openMenu', source, {
        favorites = favorites
    })
end)

RegisterNetEvent('whellco_auction_favorites:closeMenu', function()
    TriggerClientEvent('whellco_auction_favorites:closeMenu', source)
end)

RegisterNetEvent('whellco_auction_favorites:addFavorite', function(auctionId)
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    MySQL.query.await(
        [[
            INSERT INTO whellco_auction_favorites
                (character_id, auction_id)
            VALUES (?, ?)
            ON DUPLICATE KEY UPDATE character_id = VALUES(character_id)
        ]],
        { Player.PlayerData.citizenid, auctionId }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Auction added to favorites.', 'success')
end)