local QBCore = exports['qb-core']:GetCoreObject()

local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

RegisterNetEvent('whellco_auction_watchlist:openMenu', function()
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    local watchlist = MySQL.query.await(
        [[
            SELECT id, auction_id, created_at
            FROM whellco_auction_watchlist
            WHERE character_id = ?
            ORDER BY created_at DESC
            LIMIT 25
        ]],
        { Player.PlayerData.citizenid }
    ) or {}

    TriggerClientEvent('whellco_auction_watchlist:openMenu', source, {
        watchlist = watchlist
    })
end)

RegisterNetEvent('whellco_auction_watchlist:closeMenu', function()
    TriggerClientEvent('whellco_auction_watchlist:closeMenu', source)
end)

RegisterNetEvent('whellco_auction_watchlist:addAuction', function(auctionId)
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    MySQL.query.await(
        [[
            INSERT INTO whellco_auction_watchlist
                (character_id, auction_id)
            VALUES (?, ?)
            ON DUPLICATE KEY UPDATE character_id = VALUES(character_id)
        ]],
        { Player.PlayerData.citizenid, auctionId }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Auction added to watchlist.', 'success')
end)