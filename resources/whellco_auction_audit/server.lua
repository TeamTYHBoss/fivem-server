local function getIdentifier(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')

    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'steam')
    end

    return identifier
end

local function sendMenu(source)
    local logs = MySQL.query.await(
        [[
            SELECT id, auction_id, actor_id, action, details, created_at
            FROM whellco_auction_audit
            ORDER BY created_at DESC
            LIMIT ?
        ]],
        { Config.MaxAuditResults }
    ) or {}

    TriggerClientEvent('whellco_auction_audit:openMenu', source, {
        logs = logs,
        actions = Config.AuditActions
    })
end

RegisterNetEvent('whellco_auction_audit:openMenu', function()
    if not IsPlayerAceAllowed(source, Config.AuditPermission) then
        return
    end

    sendMenu(source)
end)

RegisterNetEvent('whellco_auction_audit:closeMenu', function()
    TriggerClientEvent('whellco_auction_audit:closeMenu', source)
end)

RegisterNetEvent('whellco_auction_audit:recordAudit', function(auctionId, action, details)
    local source = source

    if not IsPlayerAceAllowed(source, Config.AuditPermission) then
        return
    end

    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    action = tostring(action or '')
    details = tostring(details or ''):sub(1, Config.MaxDetailsLength)

    if not Config.AuditActions[action] then
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_auction_audit
                (auction_id, actor_id, action, details)
            VALUES (?, ?, ?, ?)
        ]],
        { auctionId, identifier, action, details }
    )

    TriggerClientEvent('whellco_auction_audit:notify', source, ('Audit recorded: %s.'):format(Config.AuditActions[action]))

    sendMenu(source)
end)
