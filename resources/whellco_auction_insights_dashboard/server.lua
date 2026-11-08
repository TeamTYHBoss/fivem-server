local QBCore = exports['qb-core']:GetCoreObject()

local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

local function sendMenu(source, filter)
    filter = tostring(filter or 'all')

    if not Config.DashboardFilters[filter] then
        filter = 'all'
    end

    local insights

    if filter == 'all' then
        insights = MySQL.query.await(
            [[
                SELECT id, auction_id, category, metric, value, created_at
                FROM whellco_auction_insights_dashboard
                ORDER BY created_at DESC
                LIMIT ?
            ]],
            { Config.MaxDashboardResults }
        ) or {}
    else
        insights = MySQL.query.await(
            [[
                SELECT id, auction_id, category, metric, value, created_at
                FROM whellco_auction_insights_dashboard
                WHERE category = ?
                ORDER BY created_at DESC
                LIMIT ?
            ]],
            { filter, Config.MaxDashboardResults }
        ) or {}
    end

    TriggerClientEvent('whellco_auction_insights_dashboard:openMenu', source, {
        insights = insights,
        filters = Config.DashboardFilters
    })
end

RegisterNetEvent('whellco_auction_insights_dashboard:openMenu', function()
    if not QBCore.Functions.HasPermission(source, 'admin') then
        return
    end

    sendMenu(source, 'all')
end)

RegisterNetEvent('whellco_auction_insights_dashboard:closeMenu', function()
    TriggerClientEvent('whellco_auction_insights_dashboard:closeMenu', source)
end)

RegisterNetEvent('whellco_auction_insights_dashboard:filterDashboard', function(filter)
    if not QBCore.Functions.HasPermission(source, 'admin') then
        return
    end

    sendMenu(source, filter)
end)

RegisterNetEvent('whellco_auction_insights_dashboard:recordInsight', function(auctionId, category, metric, value)
    local source = source
    local Player = getQbPlayer(source)

    if not Player or not QBCore.Functions.HasPermission(source, 'admin') then
        return
    end

    category = tostring(category or '')
    metric = tostring(metric or '')
    value = tonumber(value) or 0

    if not Config.DashboardFilters[category] then
        return
    end

    if #metric == 0 or #metric > 32 then
        return
    end

    MySQL.query.await(
        [[
            INSERT INTO whellco_auction_insights_dashboard
                (auction_id, category, metric, value)
            VALUES (?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
                value = VALUES(value),
                created_at = CURRENT_TIMESTAMP
        ]],
        { auctionId, category, metric, value }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Dashboard insight recorded.', 'success')

    sendMenu(source, category)
end)