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

    local recommendations = MySQL.query.await(
        [[
            SELECT id, auction_id, recommendation_type, score, reason, created_at
            FROM whellco_auction_recommendations
            WHERE character_id = (
                SELECT character_id FROM whellco_players WHERE identifier = ? ORDER BY created_at DESC LIMIT 1
            )
            ORDER BY score DESC, created_at DESC
            LIMIT ?
        ]],
        { identifier, Config.MaxRecommendations }
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
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local account = MySQL.single.await(
        [[
            SELECT character_id
            FROM whellco_players
            WHERE identifier = ?
            ORDER BY created_at DESC
            LIMIT 1
        ]],
        { identifier }
    )

    if not account then
        return
    end

    MySQL.query.await(
        [[
            DELETE FROM whellco_auction_recommendations
            WHERE character_id = ?
        ]],
        { account.character_id }
    )

    local recommendations = {}

    for index, recommendationType in ipairs(Config.RecommendationTypes) do
        recommendations[#recommendations + 1] = {
            character_id = account.character_id,
            auction_id = index,
            recommendation_type = recommendationType,
            score = 100 - (index * 10),
            reason = ('Recommended through %s.'):format(recommendationType)
        }
    end

    for _, recommendation in ipairs(recommendations) do
        MySQL.insert.await(
            [[
                INSERT INTO whellco_auction_recommendations
                    (character_id, auction_id, recommendation_type, score, reason)
                VALUES (?, ?, ?, ?, ?)
            ]],
            {
                recommendation.character_id,
                recommendation.auction_id,
                recommendation.recommendation_type,
                recommendation.score,
                recommendation.reason
            }
        )
    end

    TriggerClientEvent('whellco_auction_recommendations:notify', source, 'Recommendations refreshed.')

    sendMenu(source)
end)
