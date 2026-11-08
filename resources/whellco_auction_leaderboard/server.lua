local QBCore = exports['qb-core']:GetCoreObject()

local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

RegisterNetEvent('whellco_auction_leaderboard:openMenu', function()
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    local leaderboard = MySQL.query.await(
        [[
            SELECT id, auction_id, metric, value, created_at
            FROM whellco_auction_leaderboard
            WHERE character_id = ?
            ORDER BY value DESC
            LIMIT 25
        ]],
        { Player.PlayerData.citizenid }
    ) or {}

    TriggerClientEvent('whellco_auction_leaderboard:openMenu', source, {
        leaderboard = leaderboard
    })
end)

RegisterNetEvent('whellco_auction_leaderboard:closeMenu', function()
    TriggerClientEvent('whellco_auction_leaderboard:closeMenu', source)
end)

RegisterNetEvent('whellco_auction_leaderboard:recordScore', function(auctionId, metric, value)
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_auction_leaderboard
                (character_id, auction_id, metric, value)
            VALUES (?, ?, ?, ?)
        ]],
        { Player.PlayerData.citizenid, auctionId, metric, value }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Leaderboard score recorded.', 'success')
end)