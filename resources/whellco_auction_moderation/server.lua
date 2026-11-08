local QBCore = exports['qb-core']:GetCoreObject()

local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

local function sendMenu(source)
    local logs = MySQL.query.await(
        [[
            SELECT id, auction_id, moderator_id, action, note, created_at
            FROM whellco_auction_moderation
            ORDER BY created_at DESC
            LIMIT 25
        ]]
    ) or {}

    TriggerClientEvent('whellco_auction_moderation:openMenu', source, {
        actions = Config.ModerationActions,
        logs = logs
    })
end

RegisterNetEvent('whellco_auction_moderation:openMenu', function()
    if not QBCore.Functions.HasPermission(source, 'admin') then
        return
    end

    sendMenu(source)
end)

RegisterNetEvent('whellco_auction_moderation:closeMenu', function()
    TriggerClientEvent('whellco_auction_moderation:closeMenu', source)
end)

RegisterNetEvent('whellco_auction_moderation:moderateAuction', function(auctionId, action, note)
    local source = source
    local Player = getQbPlayer(source)

    if not Player or not QBCore.Functions.HasPermission(source, 'admin') then
        return
    end

    action = tostring(action or '')
    note = tostring(note or ''):sub(1, Config.MaxNoteLength)

    if not Config.ModerationActions[action] then
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_auction_moderation
                (auction_id, moderator_id, action, note)
            VALUES (?, ?, ?, ?)
        ]],
        { auctionId, Player.PlayerData.citizenid, action, note }
    )

    TriggerClientEvent('QBCore:Notify', source, ('Moderation action recorded: %s.'):format(Config.ModerationActions[action]), 'success')

    sendMenu(source)
end)