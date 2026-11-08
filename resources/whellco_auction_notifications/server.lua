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
            SELECT id, player_id, auction_id, notification_type, message, read_at, created_at
            FROM whellco_auction_notifications
            WHERE player_id = ?
            ORDER BY created_at DESC
            LIMIT ?
        ]],
        { identifier, Config.MaxNotifications }
    ) or {}

    TriggerClientEvent('whellco_auction_notifications:openMenu', source, {
        notifications = notifications
    })
end

RegisterNetEvent('whellco_auction_notifications:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_auction_notifications:closeMenu', function()
    TriggerClientEvent('whellco_auction_notifications:closeMenu', source)
end)

RegisterNetEvent('whellco_auction_notifications:createNotification', function(playerId, auctionId, notificationType, message)
    local source = source

    MySQL.insert.await(
        [[
            INSERT INTO whellco_auction_notifications
                (player_id, auction_id, notification_type, message)
            VALUES (?, ?, ?, ?)
        ]],
        { playerId, auctionId, notificationType, message }
    )

    TriggerClientEvent('whellco_auction_notifications:notify', source, message)

    sendMenu(source)
end)
