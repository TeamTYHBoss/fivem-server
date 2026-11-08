local function getIdentifier(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')

    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'steam')
    end

    return identifier
end

local function isAdmin(source)
    local identifier = getIdentifier(source)

    if not identifier then
        return false
    end

    return IsPlayerAceAllowed(source, 'whellco.admin')
end

local function recordMetric(metric, value)
    MySQL.insert.await(
        [[
            INSERT INTO whellco_monitoring_metrics
                (metric, value)
            VALUES (?, ?)
        ]],
        { metric, value }
    )
end

local function recordAlert(metric, value, threshold, message)
    MySQL.insert.await(
        [[
            INSERT INTO whellco_monitoring_alerts
                (metric, value, threshold, message)
            VALUES (?, ?, ?, ?)
        ]],
        { metric, value, threshold, message }
    )
end

local function getMetrics()
    local playerCount = #GetPlayers()

    return {
        players = playerCount,
        uptime = 0,
        cpu = 0,
        memory = 0,
        network = 0
    }
end

local function sendMenu(source)
    local metrics = getMetrics()
    local alerts = MySQL.query.await(
        [[
            SELECT id, metric, value, threshold, message, created_at
            FROM whellco_monitoring_alerts
            ORDER BY created_at DESC
            LIMIT 25
        ]]
    ) or {}

    TriggerClientEvent('whellco_monitoring:openMenu', source, {
        metrics = metrics,
        alerts = alerts
    })
end

RegisterNetEvent('whellco_monitoring:openMenu', function()
    if not isAdmin(source) then
        TriggerClientEvent('whellco_monitoring:notify', source, 'You do not have admin permissions.')
        return
    end

    sendMenu(source)
end)

RegisterNetEvent('whellco_monitoring:closeMenu', function()
    TriggerClientEvent('whellco_monitoring:closeMenu', source)
end)

RegisterNetEvent('whellco_monitoring:refreshMetrics', function()
    local source = source

    if not isAdmin(source) then
        TriggerClientEvent('whellco_monitoring:notify', source, 'You do not have admin permissions.')
        return
    end

    local metrics = getMetrics()

    for metric, value in pairs(metrics) do
        recordMetric(metric, value)

        local threshold = Config.AlertThresholds[metric]

        if threshold and value > threshold then
            recordAlert(metric, value, threshold, ('%s exceeded threshold.'):format(metric))
        end
    end

    TriggerClientEvent('whellco_monitoring:notify', source, 'Metrics refreshed.')
    sendMenu(source)
end)
