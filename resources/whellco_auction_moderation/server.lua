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
    if not IsPlayerAceAllowed(source, Config.ModeratorPermission) then
        return
    end

    sendMenu(source)
end)

RegisterNetEvent('whellco_auction_moderation:closeMenu', function()
    TriggerClientEvent('whellco_auction_moderation:closeMenu', source)
end)

RegisterNetEvent('whellco_auction_moderation:moderateAuction', function(auctionId, action, note)
    local source = source

    if not IsPlayerAceAllowed(source, Config.ModeratorPermission) then
        return
    end

    local identifier = GetPlayerIdentifierByType(source, 'license') or GetPlayerIdentifierByType(source, 'steam')

    if not identifier then
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
        { auctionId, identifier, action, note }
    )

    TriggerClientEvent('whellco_auction_moderation:notify', source, ('Moderation action recorded: %s.'):format(Config.ModerationActions[action]))

    sendMenu(source)
end)
