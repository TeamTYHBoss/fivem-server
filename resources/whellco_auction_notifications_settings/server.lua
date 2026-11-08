local QBCore = exports['qb-core']:GetCoreObject()

local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

local function sendMenu(source)
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    local settings = MySQL.single.await(
        [[
            SELECT alert_channel, auction_start, bid_placed, outbid, auction_end, auction_won, auction_lost
            FROM whellco_auction_notification_settings
            WHERE character_id = ?
            LIMIT 1
        ]],
        { Player.PlayerData.citizenid }
    ) or {}

    TriggerClientEvent('whellco_auction_notifications_settings:openMenu', source, {
        settings = settings,
        channels = Config.AlertChannels,
        preferences = Config.NotificationPreferences
    })
end

RegisterNetEvent('whellco_auction_notifications_settings:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_auction_notifications_settings:closeMenu', function()
    TriggerClientEvent('whellco_auction_notifications_settings:closeMenu', source)
end)

RegisterNetEvent('whellco_auction_notifications_settings:saveSettings', function(data)
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    local channel = tostring(data.alert_channel or 'in_game')

    if not Config.AlertChannels[channel] then
        channel = 'in_game'
    end

    local enabled = {}

    for preferenceType in pairs(Config.NotificationPreferences) do
        enabled[preferenceType] = data[preferenceType] and 1 or 0
    end

    MySQL.query.await(
        [[
            INSERT INTO whellco_auction_notification_settings
                (character_id, alert_channel, auction_start, bid_placed, outbid, auction_end, auction_won, auction_lost)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
                alert_channel = VALUES(alert_channel),
                auction_start = VALUES(auction_start),
                bid_placed = VALUES(bid_placed),
                outbid = VALUES(outbid),
                auction_end = VALUES(auction_end),
                auction_won = VALUES(auction_won),
                auction_lost = VALUES(auction_lost)
        ]],
        {
            Player.PlayerData.citizenid,
            channel,
            enabled.auction_start,
            enabled.bid_placed,
            enabled.outbid,
            enabled.auction_end,
            enabled.auction_won,
            enabled.auction_lost
        }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Notification settings saved.', 'success')

    sendMenu(source)
end)