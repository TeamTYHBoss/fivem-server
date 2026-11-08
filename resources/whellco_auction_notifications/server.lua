local function getIdentifier(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')

    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'steam')
    end

    return identifier
end

local function sendMenu(source)
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local notifications = MySQL.query.await(
        [[
            SELECT id, auction_id, notification_type, message, read_at, created_at
            FROM whellco_auction_notifications
            WHERE character_id = (
                SELECT character_id FROM whellco_players WHERE identifier = ? ORDER BY created_at DESC LIMIT 1
            )
            ORDER BY created_at DESC
            LIMIT ?
        ]],
        { identifier, Config.MaxNotifications }
    ) or {}

    TriggerClientEvent('whellco_auction_notifications:openMenu', source, {
        notifications = notifications,
        types = Config.NotificationTypes
    })
end

RegisterNetEvent('whellco_auction_notifications:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_auction_notifications:closeMenu', function()
    TriggerClientEvent('whellco_auction_notifications:closeMenu', source)
end)

RegisterNetEvent('whellco_auction_notifications:markRead', function(notificationId)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    MySQL.update.await(
        [[
            UPDATE whellco_auction_notifications
            SET read_at = CURRENT_TIMESTAMP
            WHERE id = ? AND character_id = (
                SELECT character_id FROM whellco_players WHERE identifier = ? ORDER BY created_at DESC LIMIT 1
            ) AND read_at IS NULL
        ]],
        { notificationId, identifier }
    )

    sendMenu(source)
end)

RegisterNetEvent('whellco_auction_notifications:createNotification', function(auctionId, notificationType, message)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    if not Config.NotificationTypes[notificationType] then
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_auction_notifications
                (character_id, auction_id, notification_type, message)
            SELECT character_id, ?, ?, ?
            FROM whellco_players
            WHERE identifier = ?
            ORDER BY created_at DESC
            LIMIT 1
        ]],
        { auctionId, notificationType, message, identifier }
    )

    TriggerClientEvent('whellco_auction_notifications:notify', source, 'Notification created.')

    sendMenu(source)
end)
