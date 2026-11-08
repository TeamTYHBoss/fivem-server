local QBCore = exports['qb-core']:GetCoreObject()
local MySQL = exports.oxmysql

local MAX_TRANSFER = 1000000
local MAX_LISTING_QUANTITY = 100
local MAX_LISTING_PRICE = 1000000
local ACTION_COOLDOWN = 1000
local actionCooldowns = {}

local RecoveryStates = {
    PENDING = 'pending',
    RECOVERY = 'recovery',
    RESOLVED = 'resolved'
}

local function notify(source, message, kind)
    TriggerClientEvent('QBCore:Notify', source, message, kind or 'primary', 5000)
end

local function trim(value)
    return (value:gsub('^%s+', '')):gsub('%s+$', '')
end

local function isOnCooldown(source)
    local now = GetGameTimer()
    local lastAction = actionCooldowns[source] or 0

    return now - lastAction < ACTION_COOLDOWN
end

local function setCooldown(source)
    actionCooldowns[source] = GetGameTimer()
end

AddEventHandler('playerDropped', function()
    actionCooldowns[source] = nil
end)

local function getVerifiedItemMetadata(Player, itemName)
    local item = Player.Functions.GetItemByName(itemName)

    if not item then
        return nil
    end

    return item.metadata or {}
end

QBCore.Functions.CreateCallback('whellco_computer:getState', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        cb({ bank = 0 })
        return
    end

    cb({ bank = Player.PlayerData.money.bank or 0 })
end)

QBCore.Functions.CreateCallback('whellco_computer:getShop', function(source, cb)
    cb({ items = Config.ShopItems or {} })
end)

RegisterNetEvent('whellco_computer:buyItem', function(itemId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or type(itemId) ~= 'string' then
        return
    end

    if isOnCooldown(source) then
        notify(source, 'Please wait before making another request.', 'error')
        return
    end

    local item = Config.ShopItems and Config.ShopItems[itemId]

    if not item or type(item.price) ~= 'number' or item.price < 0 then
        return
    end

    if (Player.PlayerData.money.bank or 0) < item.price then
        notify(source, 'You do not have enough money in your bank account.', 'error')
        return
    end

    if not Player.Functions.AddItem(itemId, 1) then
        notify(source, 'Your inventory is full.', 'error')
        return
    end

    if not Player.Functions.RemoveMoney('bank', item.price, 'computer-shop-purchase') then
        Player.Functions.RemoveItem(itemId, 1)
        notify(source, 'Purchase failed.', 'error')
        return
    end

    setCooldown(source)
    notify(source, ('Purchased %s.'):format(item.label or itemId), 'success')
end)

RegisterNetEvent('whellco_computer:createTransfer', function(recipientId, amount)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local transferAmount = tonumber(amount)

    if not Player or type(recipientId) ~= 'string' or not transferAmount then
        return
    end

    if isOnCooldown(source) then
        notify(source, 'Please wait before making another transfer.', 'error')
        return
    end

    transferAmount = math.floor(transferAmount)

    if transferAmount < 1 or transferAmount > MAX_TRANSFER then
        notify(source, 'Invalid transfer amount.', 'error')
        return
    end

    local recipient = QBCore.Functions.GetPlayerByCitizenId(recipientId)

    if not recipient then
        notify(source, 'That player is not online.', 'error')
        return
    end

    if recipient.PlayerData.citizenid == Player.PlayerData.citizenid then
        notify(source, 'You cannot transfer money to yourself.', 'error')
        return
    end

    if (Player.PlayerData.money.bank or 0) < transferAmount then
        notify(source, 'You do not have enough money in your bank account.', 'error')
        return
    end

    setCooldown(source)

    MySQL.insert(
        [[INSERT INTO whellco_computer_transfers
            (sender_citizenid, recipient_citizenid, amount, status)
          VALUES (?, ?, ?, ?)]],
        {
            Player.PlayerData.citizenid,
            recipient.PlayerData.citizenid,
            transferAmount,
            RecoveryStates.PENDING
        },
        function(insertId)
            if not insertId then
                notify(source, 'Transfer could not be started.', 'error')
                return
            end

            local sender = QBCore.Functions.GetPlayerByCitizenId(Player.PlayerData.citizenid)
            local receiver = QBCore.Functions.GetPlayerByCitizenId(recipientId)

            if not sender or not receiver then
                MySQL.update(
                    'UPDATE whellco_computer_transfers SET status = ? WHERE id = ?',
                    { RecoveryStates.RECOVERY, insertId }
                )
                notify(source, 'Transfer could not be completed.', 'error')
                return
            end

            if not sender.Functions.RemoveMoney('bank', transferAmount, 'computer-transfer') then
                MySQL.update(
                    'UPDATE whellco_computer_transfers SET status = ? WHERE id = ?',
                    { RecoveryStates.RECOVERY, insertId }
                )
                notify(source, 'Transfer failed.', 'error')
                return
            end

            if not receiver.Functions.AddMoney('bank', transferAmount, 'computer-transfer') then
                sender.Functions.AddMoney('bank', transferAmount, 'computer-transfer-refund')
                MySQL.update(
                    'UPDATE whellco_computer_transfers SET status = ? WHERE id = ?',
                    { RecoveryStates.RECOVERY, insertId }
                )
                notify(source, 'Transfer failed and was refunded.', 'error')
                return
            end

            MySQL.update(
                'UPDATE whellco_computer_transfers SET status = ? WHERE id = ?',
                { 'completed', insertId }
            )

            notify(source, ('Sent $%d.'):format(transferAmount), 'success')
            notify(receiver.PlayerData.source, ('Received $%d.'):format(transferAmount), 'success')
        end
    )
end)

RegisterNetEvent('whellco_computer:createListing', function(itemName, quantity, price)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local listingQuantity = tonumber(quantity)
    local listingPrice = tonumber(price)

    if not Player or type(itemName) ~= 'string' or not listingQuantity or not listingPrice then
        return
    end

    if isOnCooldown(source) then
        notify(source, 'Please wait before creating another listing.', 'error')
        return
    end

    listingQuantity = math.floor(listingQuantity)
    listingPrice = math.floor(listingPrice)

    if listingQuantity < 1 or listingQuantity > MAX_LISTING_QUANTITY then
        notify(source, 'Invalid listing quantity.', 'error')
        return
    end

    if listingPrice < 1 or listingPrice > MAX_LISTING_PRICE then
        notify(source, 'Invalid listing price.', 'error')
        return
    end

    local inventoryItem = Player.Functions.GetItemByName(itemName)

    if not inventoryItem or (inventoryItem.amount or 0) < listingQuantity then
        notify(source, 'You do not have enough of that item.', 'error')
        return
    end

    setCooldown(source)

    local metadata = getVerifiedItemMetadata(Player, itemName) or {}

    MySQL.insert(
        [[INSERT INTO whellco_computer_listings
            (seller_citizenid, item_name, quantity, price, metadata, status)
          VALUES (?, ?, ?, ?, ?, ?)]],
        {
            Player.PlayerData.citizenid,
            itemName,
            listingQuantity,
            listingPrice,
            json.encode(metadata),
            'active'
        },
        function(insertId)
            if insertId then
                notify(source, 'Listing created.', 'success')
            else
                notify(source, 'Could not create listing.', 'error')
            end
        end
    )
end)

RegisterNetEvent('whellco_computer:buyListing', function(listingId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local listingIdNumber = tonumber(listingId)

    if not Player or not listingIdNumber then
        return
    end

    if isOnCooldown(source) then
        notify(source, 'Please wait before making another purchase.', 'error')
        return
    end

    setCooldown(source)

    MySQL.query(
        [[SELECT id, seller_citizenid, item_name, quantity, price
          FROM whellco_computer_listings
          WHERE id = ? AND status = 'active'
          LIMIT 1]],
        { listingIdNumber },
        function(listings)
            local listing = listings and listings[1]

            if not listing then
                notify(source, 'That listing is no longer available.', 'error')
                return
            end

            if listing.seller_citizenid == Player.PlayerData.citizenid then
                notify(source, 'You cannot buy your own listing.', 'error')
                return
            end

            if (Player.PlayerData.money.bank or 0) < listing.price then
                notify(source, 'You do not have enough money in your bank account.', 'error')
                return
            end

            MySQL.update(
                [[UPDATE whellco_computer_listings
                  SET status = ?, buyer_citizenid = ?
                  WHERE id = ? AND status = 'active']],
                { 'sold', Player.PlayerData.citizenid, listing.id },
                function(affectedRows)
                    if not affectedRows or affectedRows ~= 1 then
                        notify(source, 'That listing is no longer available.', 'error')
                        return
                    end

                    if not Player.Functions.AddItem(listing.item_name, listing.quantity) then
                        MySQL.update(
                            [[UPDATE whellco_computer_listings
                              SET status = ?, buyer_citizenid = NULL
                              WHERE id = ?]],
                            { 'active', listing.id }
                        )
                        notify(source, 'Your inventory is full.', 'error')
                        return
                    end

                    if not Player.Functions.RemoveMoney('bank', listing.price, 'computer-marketplace-purchase') then
                        Player.Functions.RemoveItem(listing.item_name, listing.quantity)
                        MySQL.update(
                            [[UPDATE whellco_computer_listings
                              SET status = ?, buyer_citizenid = NULL
                              WHERE id = ?]],
                            { 'active', listing.id }
                        )
                        notify(source, 'Purchase failed.', 'error')
                        return
                    end

                    local seller = QBCore.Functions.GetPlayerByCitizenId(listing.seller_citizenid)

                    if seller then
                        seller.Functions.AddMoney('bank', listing.price, 'computer-marketplace-sale')
                        notify(seller.PlayerData.source, ('Sold %dx %s for $%d.'):format(listing.quantity, listing.item_name, listing.price), 'success')
                    end

                    notify(source, ('Purchased %dx %s.'):format(listing.quantity, listing.item_name), 'success')
                end
            )
        end
    )
end)

RegisterNetEvent('whellco_computer:cancelListing', function(listingId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local listingIdNumber = tonumber(listingId)

    if not Player or not listingIdNumber then
        return
    end

    if isOnCooldown(source) then
        notify(source, 'Please wait before making another request.', 'error')
        return
    end

    setCooldown(source)

    MySQL.update(
        [[UPDATE whellco_computer_listings
          SET status = 'cancelled'
          WHERE id = ? AND seller_citizenid = ? AND status = 'active']],
        { listingIdNumber, Player.PlayerData.citizenid },
        function(affectedRows)
            if affectedRows and affectedRows > 0 then
                notify(source, 'Listing cancelled.', 'success')
            else
                notify(source, 'Listing could not be cancelled.', 'error')
            end
        end
    )
end)

RegisterNetEvent('whellco_computer:createPost', function(content)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or type(content) ~= 'string' then
        return
    end

    content = trim(content)

    if #content == 0 or #content > 500 then
        notify(source, 'Post must be between 1 and 500 characters.', 'error')
        return
    end

    if isOnCooldown(source) then
        notify(source, 'Please wait before posting again.', 'error')
        return
    end

    setCooldown(source)

    MySQL.insert(
        'INSERT INTO whellco_computer_posts (citizenid, content) VALUES (?, ?)',
        { Player.PlayerData.citizenid, content },
        function(insertId)
            if insertId then
                notify(source, 'Post created.', 'success')
            else
                notify(source, 'Could not create post.', 'error')
            end
        end
    )
end)

RegisterNetEvent('whellco_computer:createComment', function(postId, content)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local postIdNumber = tonumber(postId)

    if not Player or not postIdNumber or type(content) ~= 'string' then
        return
    end

    content = trim(content)

    if #content == 0 or #content > 300 then
        notify(source, 'Comment must be between 1 and 300 characters.', 'error')
        return
    end

    if isOnCooldown(source) then
        notify(source, 'Please wait before commenting again.', 'error')
        return
    end

    setCooldown(source)

    MySQL.query(
        'SELECT citizenid FROM whellco_computer_posts WHERE id = ? LIMIT 1',
        { postIdNumber },
        function(posts)
            local post = posts and posts[1]

            if not post then
                notify(source, 'Post not found.', 'error')
                return
            end

            MySQL.insert(
                'INSERT INTO whellco_computer_comments (post_id, citizenid, content) VALUES (?, ?, ?)',
                { postIdNumber, Player.PlayerData.citizenid, content },
                function(insertId)
                    if not insertId then
                        notify(source, 'Could not create comment.', 'error')
                        return
                    end

                    if post.citizenid ~= Player.PlayerData.citizenid then
                        MySQL.insert(
                            [[INSERT INTO whellco_computer_notifications
                                (citizenid, type, title, message)
                              VALUES (?, ?, ?, ?)]],
                            {
                                post.citizenid,
                                'comment',
                                'New comment',
                                ('%s commented on your post.'):format(Player.PlayerData.charinfo.firstname)
                            }
                        )
                    end

                    notify(source, 'Comment created.', 'success')
                end
            )
        end
    )
end)

QBCore.Functions.CreateCallback('whellco_computer:getUnreadCount', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        cb({ count = 0 })
        return
    end

    MySQL.query(
        'SELECT COUNT(*) AS unread FROM whellco_computer_notifications WHERE citizenid = ? AND is_read = 0',
        { Player.PlayerData.citizenid },
        function(result)
            cb({ count = result and result[1] and result[1].unread or 0 })
        end
    )
end)

RegisterNetEvent('whellco_computer:markNotificationsRead', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    MySQL.update(
        'UPDATE whellco_computer_notifications SET is_read = 1 WHERE citizenid = ? AND is_read = 0',
        { Player.PlayerData.citizenid }
    )
end)

QBCore.Commands.Add('computerrecovery', 'List unresolved computer recovery records', {}, false, function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    MySQL.query(
        [[SELECT id, type, status, citizenid, created_at
          FROM whellco_computer_state
          WHERE status = ?
          ORDER BY id DESC
          LIMIT 50]],
        { RecoveryStates.RECOVERY },
        function(records)
            if not records or #records == 0 then
                notify(source, 'No unresolved recovery records.', 'primary')
                return
            end

            for _, record in ipairs(records) do
                notify(
                    source,
                    ('Recovery #%s: %s (%s)'):format(record.id, record.type or 'unknown', record.citizenid or 'unknown'),
                    'error'
                )
            end
        end
    )
end, 'admin')

QBCore.Commands.Add('computerresolve', 'Resolve a computer recovery record', {{ name = 'id', help = 'Recovery record ID' }}, true, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    local recordId = tonumber(args[1])

    if not Player or not recordId then
        return
    end

    MySQL.update(
        'UPDATE whellco_computer_state SET status = ? WHERE id = ? AND status = ?',
        { RecoveryStates.RESOLVED, recordId, RecoveryStates.RECOVERY },
        function(affectedRows)
            if affectedRows and affectedRows > 0 then
                notify(source, ('Resolved recovery record #%s.'):format(recordId), 'success')
            else
                notify(source, 'Recovery record not found or already resolved.', 'error')
            end
        end
    )
end, 'admin')