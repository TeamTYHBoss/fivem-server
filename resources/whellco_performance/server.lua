local function getIdentifier(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')

    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'steam')
    end

    return identifier
end

local function sendMenu(source)
    local metrics = {}

    for id, label in pairs(Config.PerformanceMetrics) do
        metrics[#metrics + 1] = {
            id = id,
            label = label,
            value = 0
        }
    end

    TriggerClientEvent('whellco_performance:openMenu', source, {
        metrics = metrics,
        loadOrder = Config.LoadOrder
    })
end

RegisterNetEvent('whellco_performance:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_performance:closeMenu', function()
    TriggerClientEvent('whellco_performance:closeMenu', source)
end)

RegisterNetEvent('whellco_performance:optimizeResource', function(resource)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    if not GetResourceState(resource) == 'started' then
        TriggerClientEvent('whellco_performance:notify', source, 'Resource is not running.')
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_performance_logs
                (metric, value)
            VALUES ('optimization', 1)
        ]]
    )

    TriggerClientEvent('whellco_performance:notify', source, ('Optimized %s.'):format(resource))
    sendMenu(source)
end)
