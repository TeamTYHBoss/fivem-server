local rateLimits = {}

local function getIdentifier(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')

    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'steam')
    end

    return identifier
end

local function isAllowed(identifier)
    local now = GetGameTimer()
    local limit = Config.RateLimits.default
    local entry = rateLimits[identifier]

    if not entry or now - entry.windowStart > limit.windowMs then
        rateLimits[identifier] = {
            count = 1,
            windowStart = now
        }

        return true
    end

    entry.count = entry.count + 1

    return entry.count <= limit.maxRequests
end

local function logEvent(eventType, identifier, details)
    MySQL.insert.await(
        [[
            INSERT INTO whellco_security_events
                (event_type, identifier, details)
            VALUES (?, ?, ?)
        ]],
        { eventType, identifier, details }
    )
end

local function sendMenu(source)
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local rules = {}

    for id, rule in pairs(Config.SecurityRules) do
        rules[#rules + 1] = {
            id = id,
            label = rule
        }
    end

    local events = MySQL.query.await(
        [[
            SELECT id, event_type, identifier, details, created_at
            FROM whellco_security_events
            ORDER BY created_at DESC
            LIMIT 25
        ]]
    ) or {}

    TriggerClientEvent('whellco_security:openMenu', source, {
        rules = rules,
        events = events
    })
end

RegisterNetEvent('whellco_security:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_security:closeMenu', function()
    TriggerClientEvent('whellco_security:closeMenu', source)
end)

RegisterNetEvent('whellco_security:validateInput', function(input)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    if not isAllowed(identifier) then
        TriggerClientEvent('whellco_security:notify', source, 'Too many requests. Please slow down.')
        return
    end

    if type(input) ~= 'string' or #input == 0 or #input > 255 then
        logEvent('invalid_input', identifier, tostring(input))
        TriggerClientEvent('whellco_security:notify', source, 'Invalid input.')
        return
    end

    logEvent('valid_input', identifier, input)
    TriggerClientEvent('whellco_security:notify', source, 'Input accepted.')
end)
