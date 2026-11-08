local function sendMenu(source)
    local analytics = MySQL.query.await(
        [[
            SELECT id, auction_id, metric, value, created_at
            FROM whellco_auction_analytics
            ORDER BY created_at DESC
            LIMIT ?
        ]],
        { Config.MaxAnalyticsResults }
    ) or {}

    TriggerClientEvent('whellco_auction_analytics:openMenu', source, {
        analytics = analytics
    })
end

RegisterNetEvent('whellco_auction_analytics:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_auction_analytics:closeMenu', function()
    TriggerClientEvent('whellco_auction_analytics:closeMenu', source)
end)

RegisterNetEvent('whellco_auction_analytics:recordMetric', function(auctionId, metric, value)
    local source = source

    metric = tostring(metric or '')

    if not value then
        return
    end

    value = tonumber(value) or 0

    if #metric == 0 or #metric > 32 then
        return
    end

    MySQL.query.await(
        [[
            INSERT INTO whellco_auction_analytics
                (auction_id, metric, value)
            VALUES (?, ?, ?)
            ON DUPLICATE KEY UPDATE
                value = VALUES(value),
                created_at = CURRENT_TIMESTAMP
        ]],
        { auctionId, metric, value }
    )

    TriggerClientEvent('whellco_auction_analytics:notify', source, ('Analytics recorded: %s.'):format(metric))

    sendMenu(source)
end)
