local QBCore = exports['qb-core']:GetCoreObject()

local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
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
    if not QBCore.Functions.HasPermission(source, 'admin') then
        return
    end

    sendMenu(source)
end)

RegisterNetEvent('whellco_auction_audit:closeMenu', function()
    TriggerClientEvent('whellco_auction_audit:closeMenu', source)
end)

RegisterNetEvent('whellco_auction_audit:recordAudit', function(auctionId, action, details)
    local source = source
    local Player = getQbPlayer(source)

    if not Player or not QBCore.Functions.HasPermission(source, 'admin') then
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
        { auctionId, Player.PlayerData.citizenid, action, details }
    )

    TriggerClientEvent('QBCore:Notify', source, ('Audit recorded: %s.'):format(Config.AuditActions[action]), 'success')

    sendMenu(source)
end)