local QBCore = exports['qb-core']:GetCoreObject()

local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

local function sendMenu(source)
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    local recommendations = MySQL.query.await(
        [[
            SELECT id, auction_id, recommendation_type, score, reason, created_at
            FROM whellco_auction_recommendations
            WHERE character_id = ?
            ORDER BY score DESC, created_at DESC
            LIMIT ?
        ]],
        { Player.PlayerData.citizenid, Config.MaxRecommendations }
    ) or {}

    TriggerClientEvent('whellco_auction_recommendations:openMenu', source, {
        recommendations = recommendations,
        types = Config.RecommendationTypes
    })
end

RegisterNetEvent('whellco_auction_recommendations:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_auction_recommendations:closeMenu', function()
    TriggerClientEvent('whellco_auction_recommendations:closeMenu', source)
end)

RegisterNetEvent('whellco_auction_recommendations:generateRecommendations', function()
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    local citizenId = Player.PlayerData.citizenid

    MySQL.query.await(
        [[
            DELETE FROM whellco_auction_recommendations
            WHERE character_id = ?
        ]],
        { citizenId }
    )

    local index = 0

    for recommendationType in pairs(Config.RecommendationTypes) do
        index = index + 1

        MySQL.insert.await(
            [[
                INSERT INTO whellco_auction_recommendations
                    (character_id, auction_id, recommendation_type, score, reason)
                VALUES (?, ?, ?, ?, ?)
            ]],
            { citizenId, index, recommendationType, 100 - (index * 10), ('Recommended through %s.'):format(recommendationType) }
        )
    end

    TriggerClientEvent('QBCore:Notify', source, 'Recommendations refreshed.', 'success')

    sendMenu(source)
end)