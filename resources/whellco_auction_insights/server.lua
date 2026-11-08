local QBCore = exports['qb-core']:GetCoreObject()

local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

local function sendMenu(source)
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    local insights = MySQL.query.await(
        [[
            SELECT id, auction_id, category, insight, score, created_at
            FROM whellco_auction_insights
            WHERE character_id = ?
            ORDER BY created_at DESC
            LIMIT ?
        ]],
        { Player.PlayerData.citizenid, Config.MaxInsights }
    ) or {}

    TriggerClientEvent('whellco_auction_insights:openMenu', source, {
        insights = insights,
        categories = Config.InsightCategories
    })
end

RegisterNetEvent('whellco_auction_insights:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_auction_insights:closeMenu', function()
    TriggerClientEvent('whellco_auction_insights:closeMenu', source)
end)

RegisterNetEvent('whellco_auction_insights:addInsight', function(auctionId, category, insight, score)
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    category = tostring(category or '')
    insight = tostring(insight or '')
    score = tonumber(score) or 0

    if not Config.InsightCategories[category] then
        return
    end

    if #insight == 0 or #insight > 255 then
        return
    end

    if score < 0 or score > 100 then
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_auction_insights
                (auction_id, category, insight, score)
            VALUES (?, ?, ?, ?)
        ]],
        { auctionId, category, insight, score }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Insight added.', 'success')

    sendMenu(source)
end)