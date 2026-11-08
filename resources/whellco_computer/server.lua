local QBCore = exports['qb-core']:GetCoreObject()
local MySQL = exports.oxmysql

local posts = {}
local nextPostId = 1

local function notify(source, title, message, kind)
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

QBCore.Functions.CreateCallback('whellco_computer:getBankBalance', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        cb(0)
        return
    end

    cb(Player.PlayerData.money.bank or 0)
end)

QBCore.Functions.CreateCallback('whellco_computer:getShop', function(source, cb)
    cb(Config.Shop)
end)

QBCore.Functions.CreateCallback('whellco_computer:buyItem', function(source, cb, itemId)
    local Player = QBCore.Functions.GetPlayer(source)
    local item = Config.Shop[itemId]

    if not Player or not item then
        cb(false, 'Item not found')
        return
    end

    local bank = Player.PlayerData.money.bank or 0

    if bank < item.price then
        cb(false, 'Not enough money in bank')
        return
    end

    Player.Functions.RemoveMoney('bank', item.price, 'computer-shop')

    if not Player.Functions.AddItem(item.item, 1) then
        Player.Functions.AddMoney('bank', item.price, 'computer-shop-refund')
        cb(false, 'Inventory full')
        return
    end

    cb(true, ('Purchased %s for $%s'):format(item.label, item.price))
end)

QBCore.Functions.CreateCallback('whellco_computer:transferMoney', function(source, cb, data)
    local sender = QBCore.Functions.GetPlayer(source)

    if not sender then
        cb(false, 'Sender not found')
        return
    end

    if type(data) ~= 'table' or not data.recipient or not data.amount or not data.requestId then
        cb(false, 'Invalid transfer request')
        return
    end

    local amount = tonumber(data.amount)

    if not amount or amount <= 0 or amount ~= math.floor(amount) then
        cb(false, 'Transfer amount must be a positive whole number')
        return
    end

    if data.recipient == sender.PlayerData.citizenid then
        cb(false, 'You cannot transfer money to yourself')
        return
    end

    MySQL.scalar('SELECT id FROM whellco_computer_transfers WHERE request_id = ?', {
        data.requestId
    }, function(existing)
        if existing then
            cb(false, 'Transfer already processed')
            return
        end

        local recipient = getPlayerByCitizenId(data.recipient)

        if not recipient then
            cb(false, 'Recipient is not online')
            return
        end

        local senderBank = sender.PlayerData.money.bank or 0

        if senderBank < amount then
            cb(false, 'Not enough money in bank')
            return
        end

        MySQL.insert('INSERT INTO whellco_computer_transfers (request_id, sender, recipient, amount, status) VALUES (?, ?, ?, ?, ?)', {
            data.requestId,
            sender.PlayerData.citizenid,
            recipient.PlayerData.citizenid,
            amount,
            'pending'
        }, function(transferId)
            if not transferId then
                cb(false, 'Could not create transfer record')
                return
            end

            if not sender.Functions.RemoveMoney('bank', amount, 'computer-transfer') then
                MySQL.update('UPDATE whellco_computer_transfers SET status = ? WHERE id = ?', {
                    'failed',
                    transferId
                })
                cb(false, 'Transfer failed')
                return
            end

            recipient.Functions.AddMoney('bank', amount, 'computer-transfer')

            MySQL.update('UPDATE whellco_computer_transfers SET status = ? WHERE id = ?', {
                'completed',
                transferId
            })

            MySQL.insert('INSERT INTO whellco_computer_notifications (citizenid, kind, reference_id, content) VALUES (?, ?, ?, ?)', {
                recipient.PlayerData.citizenid,
                'transfer',
                transferId,
                ('%s sent you $%s'):format(sender.PlayerData.charinfo.firstname, amount)
            })

            notify(recipient.PlayerData.source, 'Bank Transfer', ('You received $%s from %s'):format(amount, sender.PlayerData.charinfo.firstname), 'success')
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
        Player.PlayerData.citizenid,
        Player.PlayerData.citizenid
    }, function(rows)
        cb(rows or {})
    end)
end)

QBCore.Functions.CreateCallback('whellco_computer:createListing', function(source, cb, data)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        cb(false, 'Player not found')
        return
    end

    if type(data) ~= 'table' or not data.item or not data.quantity or not data.price then
        cb(false, 'Invalid listing request')
        return
    end

    local quantity = tonumber(data.quantity)
    local price = tonumber(data.price)

    if not quantity or quantity <= 0 or quantity ~= math.floor(quantity) then
        cb(false, 'Quantity must be a positive whole number')
        return
    end

    if not price or price <= 0 or price ~= math.floor(price) then
        cb(false, 'Price must be a positive whole number')
        return
    end

    if not Player.Functions.RemoveItem(data.item, quantity) then
        cb(false, 'You do not have enough of that item')
        return
    end

    local metadata = json.encode(data.metadata or {})

    MySQL.insert('INSERT INTO whellco_computer_listings (seller, item, quantity, metadata, price, status) VALUES (?, ?, ?, ?, ?, ?)', {
        Player.PlayerData.citizenid,
        data.item,
        quantity,
        metadata,
        price,
        'active'
    }, function(listingId)
        if not listingId then
            Player.Functions.AddItem(data.item, quantity, false, data.metadata or {})
            cb(false, 'Could not create listing')
            return
        end

        cb(true, 'Listing created')
    end)
end)

QBCore.Functions.CreateCallback('whellco_computer:getMarketplace', function(source, cb)
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

    MySQL.single('SELECT seller, item, quantity, metadata, status FROM whellco_computer_listings WHERE id = ?', {
        listingId
    }, function(listing)
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

        MySQL.update('UPDATE whellco_computer_listings SET status = ? WHERE id = ?', {
            'cancelled',
            listingId
        }, function(affected)
            if not affected then
                cb(false, 'Could not cancel listing')
                return
            end

            Player.Functions.AddItem(listing.item, listing.quantity, false, json.decode(listing.metadata or '{}'))
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

    MySQL.single('SELECT id, seller, item, quantity, metadata, price, status FROM whellco_computer_listings WHERE id = ?', {
        listingId
    }, function(listing)
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

        local seller = getPlayerByCitizenId(listing.seller)

        if not seller then
            cb(false, 'Seller is not online')
            return
        end

        local buyerBank = buyer.PlayerData.money.bank or 0

        if buyerBank < listing.price then
            cb(false, 'Not enough money in bank')
            return
        end

        local metadata = json.decode(listing.metadata or '{}')

        if not buyer.Functions.AddItem(listing.item, listing.quantity, false, metadata) then
            cb(false, 'Inventory full')
            return
        end

        if not buyer.Functions.RemoveMoney('bank', listing.price, 'computer-marketplace') then
            buyer.Functions.RemoveItem(listing.item, listing.quantity, false, metadata)
            cb(false, 'Purchase failed')
            return
        end

        MySQL.transaction({
            'UPDATE whellco_computer_listings SET status = ?, buyer = ? WHERE id = ? AND status = ?',
            'INSERT INTO whellco_computer_notifications (citizenid, kind, reference_id, content) VALUES (?, ?, ?, ?)'
        }, {
            {
                'sold',
                buyer.PlayerData.citizenid,
                listingId,
                'active'
            },
            {
                seller.PlayerData.citizenid,
                'marketplace',
                listingId,
                ('%s bought your listing for $%s'):format(buyer.PlayerData.charinfo.firstname, listing.price)
            }
        }, function(success)
            if not success then
                buyer.Functions.AddMoney('bank', listing.price, 'computer-marketplace-refund')
                buyer.Functions.RemoveItem(listing.item, listing.quantity, false, metadata)
                cb(false, 'Purchase failed')
                return
            end

            seller.Functions.AddMoney('bank', listing.price, 'computer-marketplace-sale')

            notify(seller.PlayerData.source, 'Marketplace Sale', ('%s bought your listing for $%s'):format(buyer.PlayerData.charinfo.firstname, listing.price), 'success')
            cb(true, ('Bought %s x%s for $%s'):format(listing.item, listing.quantity, listing.price))
        end)
    end)
end)

QBCore.Functions.CreateCallback('whellco_computer:createPost', function(source, cb, content)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        cb(false, 'Player not found')
        return
    end

    if not content or type(content) ~= 'string' then
        cb(false, 'Invalid post')
        return
    end

    content = content:sub(1, 500)

    if #content < 1 then
        cb(false, 'Post cannot be empty')
        return
    end

    local post = {
        id = nextPostId,
        author = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        content = content,
        comments = {},
        time = os.time()
    }

    posts[nextPostId] = post
    nextPostId = nextPostId + 1

    cb(true, 'Post created')
end)

QBCore.Functions.CreateCallback('whellco_computer:getPosts', function(source, cb)
    local result = {}

    for _, post in pairs(posts) do
        result[#result + 1] = post
    end

    table.sort(result, function(a, b)
        return a.time > b.time
    end)

    cb(result)
end)

QBCore.Functions.CreateCallback('whellco_computer:addComment', function(source, cb, postId, content)
    local Player = QBCore.Functions.GetPlayer(source)
    local post = posts[postId]

    if not Player or not post then
        cb(false, 'Post not found')
        return
    end

    if not content or type(content) ~= 'string' then
        cb(false, 'Invalid comment')
        return
    end

    content = content:sub(1, 300)

    if #content < 1 then
        cb(false, 'Comment cannot be empty')
        return
    end

    post.comments[#post.comments + 1] = {
        author = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        content = content,
        time = os.time()
    }

    cb(true, 'Comment added')
end)