local QBCore = exports['qb-core']:GetCoreObject()

local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

local function sendMenu(source)
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    local notifications = MySQL.query.await(
        [[
            SELECT id, auction_id, notification_type, message, read_at, created_at
            FROM whellco_auction_notifications
            WHERE character_id = ?
            ORDER BY created_at DESC
            LIMIT ?
        ]],
        { Player.PlayerData.citizenid, Config.MaxNotifications }
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
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    MySQL.update.await(
        [[
            UPDATE whellco_auction_notifications
            SET read_at = CURRENT_TIMESTAMP
            WHERE id = ? AND character_id = ? AND read_at IS NULL
        ]],
        { notificationId, Player.PlayerData.citizenid }
    )

    sendMenu(source)
end)

RegisterNetEvent('whellco_auction_notifications:createNotification', function(auctionId, notificationType, message)
    local source = source
    local Player = getQbPlayer(source)

    if not Player or not Config.NotificationTypes[notificationType] then
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_auction_notifications
                (character_id, auction_id, notification_type, message)
            VALUES (?, ?, ?, ?)
        ]],
        { Player.PlayerData.citizenid, auctionId, notificationType, message }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Notification created.', 'success')

    sendMenu(source)
end)