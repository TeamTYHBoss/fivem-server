local QBCore = exports['qb-core']:GetCoreObject()

local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

RegisterNetEvent('whellco_auction_stats:openMenu', function()
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    local stats = MySQL.query.await(
        [[
            SELECT id, auction_id, metric, value, created_at
            FROM whellco_auction_stats
            WHERE character_id = ?
            ORDER BY created_at DESC
            LIMIT 25
        ]],
        { Player.PlayerData.citizenid }
    ) or {}

    TriggerClientEvent('whellco_auction_stats:openMenu', source, {
        stats = stats
    })
end)

RegisterNetEvent('whellco_auction_stats:closeMenu', function()
    TriggerClientEvent('whellco_auction_stats:closeMenu', source)
end)

RegisterNetEvent('whellco_auction_stats:recordStat', function(auctionId, metric, value)
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_auction_stats
                (character_id, auction_id, metric, value)
            VALUES (?, ?, ?, ?)
        ]],
        { Player.PlayerData.citizenid, auctionId, metric, value }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Auction stat recorded.', 'success')
end)