QBCore.Functions.CreateCallback('whellco_computer:getNotifications', function(source, cb)
    local Player = Computer.GetPlayer(source)

    if not Player then
        cb({})
        return
    end

    Computer.MySQL.query(
        [[SELECT id, kind, reference_id, content, read_at, created_at
          FROM whellco_computer_notifications
          WHERE citizenid = ?
          ORDER BY id DESC
          LIMIT 50]],
        { Player.PlayerData.citizenid },
        function(notifications)
            cb(notifications or {})
        end
    )
end)

QBCore.Functions.CreateCallback('whellco_computer:markNotificationRead', function(source, cb, notificationId)
    local Player = Computer.GetPlayer(source)
    local notificationIdNumber = Utils.ValidatePositiveInteger(notificationId, 1)

    if not Player or not notificationIdNumber then
        cb(false, 'Invalid notification request.')
        return
    end

    Computer.MySQL.update(
        [[UPDATE whellco_computer_notifications
          SET read_at = CURRENT_TIMESTAMP
          WHERE id = ? AND citizenid = ? AND read_at IS NULL]],
        {
            notificationIdNumber,
            Player.PlayerData.citizenid
        },
        function(affectedRows)
            if affectedRows and affectedRows > 0 then
                cb(true, 'Notification marked as read.')
            else
                cb(false, 'Notification could not be updated.')
            end
        end
    )
end)

QBCore.Functions.CreateCallback('whellco_computer:getUnreadCount', function(source, cb)
    local Player = Computer.GetPlayer(source)

    if not Player then
        cb(0)
        return
    end

    Computer.MySQL.query(
        [[SELECT COUNT(*) AS unread
          FROM whellco_computer_notifications
          WHERE citizenid = ? AND read_at IS NULL]],
        { Player.PlayerData.citizenid },
        function(result)
            cb(result and result[1] and result[1].unread or 0)
        end
    )
end)
