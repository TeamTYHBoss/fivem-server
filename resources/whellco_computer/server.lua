local QBCore = exports['qb-core']:GetCoreObject()
local MySQL = exports.oxmysql

local cooldowns = {}

local function isRateLimited(source, action, seconds)
    local key = source .. ':' .. action
    local now = os.time()

    if cooldowns[key] and now - cooldowns[key] < seconds then
        return true
    end

    cooldowns[key] = now
    return false
end

local function notify(source, message, kind)
    TriggerClientEvent('QBCore:Notify', source, message, kind or 'primary', 5000)
end

local function getPlayerByCitizenId(citizenId)
    for _, player in pairs(QBCore.Functions.GetQBPlayers()) do
        if player.PlayerData.citizenid == citizenId then
            return player
        end
    end

    return nil
end

local function createNotification(citizenId, kind, referenceId, content)
    MySQL.insert('INSERT INTO whellco_computer_notifications (citizenid, kind, reference_id, content) VALUES (?, ?, ?, ?)', {
        citizenId, kind, referenceId, content
    })
end

local function generateRequestId()
    return ('%d-%s-%s'):format(os.time(), math.random(100000, 999999), math.random(100000, 999999))
end

QBCore.Functions.CreateCallback('whellco_computer:getBankBalance', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    cb(Player and (Player.PlayerData.money.bank or 0) or 0)
end)

QBCore.Functions.CreateCallback('whellco_computer:getShop', function(_, cb)
    cb(Config.Shop)
end)

QBCore.Functions.CreateCallback('whellco_computer:buyItem', function(source, cb, itemId)
    local Player = QBCore.Functions.GetPlayer(source)
    local item = Config.Shop[itemId]

    if not Player or not item then
        cb(false, 'Item not found')
        return
    end

    if isRateLimited(source, 'shop', 1) then
        cb(false, 'Please wait before buying again')
        return
    end

    if (Player.PlayerData.money.bank or 0) < item.price then
        cb(false, 'Not enough money in bank')
        return
    end

    if not Player.Functions.AddItem(item.item, 1) then
        cb(false, 'Inventory full')
        return
    end

    if not Player.Functions.RemoveMoney('bank', item.price, 'computer-shop') then
        Player.Functions.RemoveItem(item.item, 1)
        cb(false, 'Purchase failed')
        return
    end

    cb(true, ('Purchased %s for $%s'):format(item.label, item.price))
end)

QBCore.Functions.CreateCallback('whellco_computer:transferMoney', function(source, cb, data)
    local sender = QBCore.Functions.GetPlayer(source)

    if not sender or type(data) ~= 'table' or not data.recipient or not data.amount then
        cb(false, 'Invalid transfer request')
        return
    end

    if isRateLimited(source, 'transfer', 2) then
        cb(false, 'Please wait before sending another transfer')
        return
    end

    local amount = tonumber(data.amount)

    if not amount or amount <= 0 or amount ~= math.floor(amount) or amount > 1000000 then
        cb(false, 'Transfer amount must be between 1 and 1000000')
        return
    end

    if data.recipient == sender.PlayerData.citizenid then
        cb(false, 'You cannot transfer money to yourself')
        return
    end

    local requestId = generateRequestId()

    MySQL.insert('INSERT INTO whellco_computer_transfers (request_id, sender, recipient, amount, status) VALUES (?, ?, ?, ?, ?)', {
        requestId, sender.PlayerData.citizenid, data.recipient, amount, 'pending'
    }, function(transferId)
        sender = QBCore.Functions.GetPlayer(source)
        local recipient = getPlayerByCitizenId(data.recipient)

        if not transferId or not sender or not recipient then
            if transferId then
                MySQL.update('UPDATE whellco_computer_transfers SET status = ? WHERE id = ?', { 'failed', transferId })
            end

            cb(false, transferId and 'Recipient is not online' or 'Could not create transfer record')
            return
        end

        if (sender.PlayerData.money.bank or 0) < amount then
            MySQL.update('UPDATE whellco_computer_transfers SET status = ? WHERE id = ?', { 'failed', transferId })
            cb(false, 'Not enough money in bank')
            return
        end

        if not sender.Functions.RemoveMoney('bank', amount, 'computer-transfer') then
            MySQL.update('UPDATE whellco_computer_transfers SET status = ? WHERE id = ?', { 'failed', transferId })
            cb(false, 'Transfer failed')
            return
        end

        if not recipient.Functions.AddMoney('bank', amount, 'computer-transfer') then
            sender.Functions.AddMoney('bank', amount, 'computer-transfer-refund')
            MySQL.update('UPDATE whellco_computer_transfers SET status = ? WHERE id = ?', { 'failed', transferId })
            cb(false, 'Recipient could not receive the transfer')
            return
        end

        MySQL.transaction({
            {
                query = 'UPDATE whellco_computer_transfers SET status = ? WHERE id = ? AND status = ?',
                values = { 'completed', transferId, 'pending' }
            },
            {
                query = 'INSERT INTO whellco_computer_notifications (citizenid, kind, reference_id, content) VALUES (?, ?, ?, ?)',
                values = {
                    recipient.PlayerData.citizenid,
                    'transfer',
                    transferId,
                    ('%s sent you $%s'):format(sender.PlayerData.charinfo.firstname, amount)
                }
            }
        }, function(success)
            recipient = getPlayerByCitizenId(data.recipient)
            sender = QBCore.Functions.GetPlayer(source)

            if not success then
                local reversed = true

                if recipient then
                    reversed = recipient.Functions.RemoveMoney('bank', amount, 'computer-transfer-reversal')
                end

                if sender then
                    sender.Functions.AddMoney('bank', amount, 'computer-transfer-refund')
                end

                MySQL.update('UPDATE whellco_computer_transfers SET status = ? WHERE id = ?', {
                    reversed and 'failed' or 'recovery', transferId
                })
                cb(false, 'Transfer failed')
                return
            end

            if recipient then
                notify(recipient.PlayerData.source, ('You received $%s from %s'):format(amount, sender.PlayerData.charinfo.firstname), 'success')
            end

            cb(true, ('Sent $%s to %s'):format(amount, recipient.PlayerData.charinfo.firstname))
        end)
    end)
end)

QBCore.Functions.CreateCallback('whellco_computer:getTransfers', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        cb({})
        return
    end

    MySQL.query('SELECT id, sender, recipient, amount, status, created_at FROM whellco_computer_transfers WHERE sender = ? OR recipient = ? ORDER BY id DESC LIMIT 50', {
        Player.PlayerData.citizenid, Player.PlayerData.citizenid
    }, function(rows)
        cb(rows or {})
    end)
end)

QBCore.Functions.CreateCallback('whellco_computer:getNotifications', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        cb({})
        return
    end

    MySQL.query('SELECT id, kind, reference_id, content, read_at, created_at FROM whellco_computer_notifications WHERE citizenid = ? ORDER BY id DESC LIMIT 50', {
        Player.PlayerData.citizenid
    }, function(rows)
        cb(rows or {})
    end)
end)

QBCore.Functions.CreateCallback('whellco_computer:getUnreadNotificationCount', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        cb(0)
        return
    end

    MySQL.scalar('SELECT COUNT(*) FROM whellco_computer_notifications WHERE citizenid = ? AND read_at IS NULL', {
        Player.PlayerData.citizenid
    }, function(count)
        cb(tonumber(count) or 0)
    end)
end)

QBCore.Functions.CreateCallback('whellco_computer:markNotificationRead', function(source, cb, notificationId)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not notificationId then
        cb(false, 'Invalid notification')
        return
    end

    MySQL.update('UPDATE whellco_computer_notifications SET read_at = CURRENT_TIMESTAMP WHERE id = ? AND citizenid = ? AND read_at IS NULL', {
        notificationId, Player.PlayerData.citizenid
    }, function(affected)
        local success = affected and affected > 0
        cb(success, success and 'Notification marked as read' or 'Notification not found')
    end)
end)

QBCore.Functions.CreateCallback('whellco_computer:createListing', function(source, cb, data)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or type(data) ~= 'table' or type(data.item) ~= 'string' then
        cb(false, 'Invalid listing request')
        return
    end

    if isRateLimited(source, 'listing', 2) then
        cb(false, 'Please wait before creating another listing')
        return
    end

    local quantity = tonumber(data.quantity)
    local price = tonumber(data.price)

    if not quantity or quantity <= 0 or quantity ~= math.floor(quantity) or quantity > 1000 then
        cb(false, 'Quantity must be between 1 and 1000')
        return
    end

    if not price or price <= 0 or price ~= math.floor(price) or price > 1000000 then
        cb(false, 'Price must be between 1 and 1000000')
        return
    end

    if data.metadata ~= nil then
        cb(false, 'Metadata cannot be supplied by the client')
        return
    end

    if not Player.Functions.RemoveItem(data.item, quantity) then
        cb(false, 'You do not have enough of that item')
        return
    end

    MySQL.insert('INSERT INTO whellco_computer_listings (seller, item, quantity, metadata, price, status) VALUES (?, ?, ?, ?, ?, ?)', {
        Player.PlayerData.citizenid, data.item, quantity, '{}', price, 'active'
    }, function(listingId)
        if not listingId then
            Player.Functions.AddItem(data.item, quantity)
            cb(false, 'Could not create listing')
            return
        end

        cb(true, 'Listing created')
    end)
end)

QBCore.Functions.CreateCallback('whellco_computer:getMarketplace', function(_, cb)
    MySQL.query('SELECT id, seller, item, quantity, metadata, price, created_at FROM whellco_computer_listings WHERE status = ? ORDER BY id DESC LIMIT 100', {
        'active'
    }, function(rows)
        local listings = {}

        for _, row in ipairs(rows or {}) do
            row.metadata = json.decode(row.metadata or '{}')
            listings[#listings + 1] = row
        end

        cb(listings)
    end)
end)

QBCore.Functions.CreateCallback('whellco_computer:cancelListing', function(source, cb, listingId)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not listingId then
        cb(false, 'Invalid listing')
        return
    end

    MySQL.single('SELECT seller, item, quantity, metadata, status FROM whellco_computer_listings WHERE id = ?', { listingId }, function(listing)
        if not listing then
            cb(false, 'Listing not found')
            return
        end

        if listing.seller ~= Player.PlayerData.citizenid then
            cb(false, 'You do not own that listing')
            return
        end

        if listing.status ~= 'active' then
            cb(false, 'Listing is no longer active')
            return
        end

        MySQL.update('UPDATE whellco_computer_listings SET status = ? WHERE id = ? AND status = ?', {
            'cancelled', listingId, 'active'
        }, function(affected)
            if not affected or affected == 0 then
                cb(false, 'Could not cancel listing')
                return
            end

            if not Player.Functions.AddItem(listing.item, listing.quantity) then
                MySQL.update('UPDATE whellco_computer_listings SET status = ? WHERE id = ?', { 'recovery', listingId })
                cb(false, 'Inventory full; listing marked for recovery')
                return
            end

            cb(true, 'Listing cancelled and item returned')
        end)
    end)
end)

QBCore.Functions.CreateCallback('whellco_computer:buyListing', function(source, cb, listingId)
    local buyer = QBCore.Functions.GetPlayer(source)

    if not buyer or not listingId then
        cb(false, 'Invalid purchase')
        return
    end

    if isRateLimited(source, 'purchase', 1) then
        cb(false, 'Please wait before purchasing again')
        return
    end

    MySQL.single('SELECT id, seller, item, quantity, metadata, price, status FROM whellco_computer_listings WHERE id = ?', { listingId }, function(listing)
        if not listing then
            cb(false, 'Listing not found')
            return
        end

        if listing.status ~= 'active' then
            cb(false, 'Listing is no longer available')
            return
        end

        if listing.seller == buyer.PlayerData.citizenid then
            cb(false, 'You cannot buy your own listing')
            return
        end

        if (buyer.PlayerData.money.bank or 0) < listing.price then
            cb(false, 'Not enough money in bank')
            return
        end

        MySQL.update('UPDATE whellco_computer_listings SET status = ?, buyer = ? WHERE id = ? AND status = ?', {
            'pending', buyer.PlayerData.citizenid, listingId, 'active'
        }, function(affected)
            if not affected or affected ~= 1 then
                cb(false, 'Listing is no longer available')
                return
            end

            buyer = QBCore.Functions.GetPlayer(source)
            local seller = getPlayerByCitizenId(listing.seller)

            if not buyer or not seller then
                MySQL.update('UPDATE whellco_computer_listings SET status = ? WHERE id = ? AND status = ?', {
                    'active', listingId, 'pending'
                })
                cb(false, 'Purchase could not be completed')
                return
            end

            if not buyer.Functions.AddItem(listing.item, listing.quantity) then
                MySQL.update('UPDATE whellco_computer_listings SET status = ? WHERE id = ? AND status = ?', {
                    'active', listingId, 'pending'
                })
                cb(false, 'Inventory full')
                return
            end

            if not buyer.Functions.RemoveMoney('bank', listing.price, 'computer-marketplace') then
                buyer.Functions.RemoveItem(listing.item, listing.quantity)
                MySQL.update('UPDATE whellco_computer_listings SET status = ? WHERE id = ? AND status = ?', {
                    'active', listingId, 'pending'
                })
                cb(false, 'Purchase failed')
                return
            end

            MySQL.transaction({
                {
                    query = 'UPDATE whellco_computer_listings SET status = ? WHERE id = ? AND status = ?',
                    values = { 'sold', listingId, 'pending' }
                },
                {
                    query = 'INSERT INTO whellco_computer_notifications (citizenid, kind, reference_id, content) VALUES (?, ?, ?, ?)',
                    values = {
                        seller.PlayerData.citizenid,
                        'marketplace',
                        listingId,
                        ('%s bought your listing for $%s'):format(buyer.PlayerData.charinfo.firstname, listing.price)
                    }
                }
            }, function(success)
                buyer = QBCore.Functions.GetPlayer(source)
                seller = getPlayerByCitizenId(listing.seller)

                if not success then
                    if buyer then
                        buyer.Functions.AddMoney('bank', listing.price, 'computer-marketplace-refund')
                        buyer.Functions.RemoveItem(listing.item, listing.quantity)
                    end

                    MySQL.update('UPDATE whellco_computer_listings SET status = ? WHERE id = ? AND status = ?', {
                        'active', listingId, 'pending'
                    })
                    cb(false, 'Purchase failed')
                    return
                end

                if seller then
                    if not seller.Functions.AddMoney('bank', listing.price, 'computer-marketplace-sale') then
                        MySQL.update('UPDATE whellco_computer_listings SET status = ? WHERE id = ?', {
                            'recovery', listingId
                        })
                        print(('[whellco_computer] Marketplace payout failed for listing %s.'):format(listingId))
                    end

                    notify(seller.PlayerData.source, ('%s bought your listing for $%s'):format(buyer.PlayerData.charinfo.firstname, listing.price), 'success')
                else
                    MySQL.update('UPDATE whellco_computer_listings SET status = ? WHERE id = ?', {
                        'recovery', listingId
                    })
                    print(('[whellco_computer] Marketplace seller offline during payout for listing %s.'):format(listingId))
                end

                cb(true, ('Bought %s x%s for $%s'):format(listing.item, listing.quantity, listing.price))
            end)
        end)
    end)
end)

QBCore.Functions.CreateCallback('whellco_computer:createPost', function(source, cb, content)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or type(content) ~= 'string' then
        cb(false, 'Invalid post')
        return
    end

    if isRateLimited(source, 'post', 3) then
        cb(false, 'Please wait before posting again')
        return
    end

    content = content:sub(1, Config.MaxPostLength)

    if #content < 1 then
        cb(false, 'Post cannot be empty')
        return
    end

    MySQL.insert('INSERT INTO whellco_computer_posts (citizenid, author, content) VALUES (?, ?, ?)', {
        Player.PlayerData.citizenid,
        Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        content
    }, function(postId)
        local success = postId and true or false
        cb(success, success and 'Post created' or 'Could not create post')
    end)
end)

QBCore.Functions.CreateCallback('whellco_computer:getPosts', function(_, cb)
    MySQL.query('SELECT id, citizenid, author, content, created_at FROM whellco_computer_posts ORDER BY id DESC LIMIT 50', {}, function(postRows)
        local posts = postRows or {}

        for _, post in ipairs(posts) do
            post.comments = {}
        end

        if #posts == 0 then
            cb(posts)
            return
        end

        local placeholders = {}
        local ids = {}

        for _, post in ipairs(posts) do
            placeholders[#placeholders + 1] = '?'
            ids[#ids + 1] = post.id
        end

        MySQL.query(('SELECT post_id, citizenid, author, content, created_at FROM whellco_computer_comments WHERE post_id IN (%s) ORDER BY id ASC'):format(table.concat(placeholders, ',')), ids, function(commentRows)
            local commentsByPost = {}

            for _, comment in ipairs(commentRows or {}) do
                commentsByPost[comment.post_id] = commentsByPost[comment.post_id] or {}
                commentsByPost[comment.post_id][#commentsByPost[comment.post_id] + 1] = comment
            end

            for _, post in ipairs(posts) do
                post.comments = commentsByPost[post.id] or {}
            end

            cb(posts)
        end)
    end)
end)

QBCore.Functions.CreateCallback('whellco_computer:addComment', function(source, cb, postId, content)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not postId or type(content) ~= 'string' then
        cb(false, 'Invalid comment')
        return
    end

    if isRateLimited(source, 'comment', 2) then
        cb(false, 'Please wait before commenting again')
        return
    end

    content = content:sub(1, Config.MaxCommentLength)

    if #content < 1 then
        cb(false, 'Comment cannot be empty')
        return
    end

    MySQL.single('SELECT citizenid FROM whellco_computer_posts WHERE id = ?', { postId }, function(post)
        if not post then
            cb(false, 'Post not found')
            return
        end

        MySQL.insert('INSERT INTO whellco_computer_comments (post_id, citizenid, author, content) VALUES (?, ?, ?, ?)', {
            postId,
            Player.PlayerData.citizenid,
            Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
            content
        }, function(commentId)
            if not commentId then
                cb(false, 'Could not add comment')
                return
            end

            if post.citizenid ~= Player.PlayerData.citizenid then
                createNotification(post.citizenid, 'comment', postId, ('%s commented on your post'):format(Player.PlayerData.charinfo.firstname))
            end

            cb(true, 'Comment added')
        end)
    end)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    MySQL.update('UPDATE whellco_computer_listings SET status = ? WHERE status = ?', {
        'recovery', 'pending'
    }, function(affected)
        if affected and affected > 0 then
            print(('[whellco_computer] Marked %d incomplete marketplace listing(s) for recovery.'):format(affected))
        end
    end)
end)