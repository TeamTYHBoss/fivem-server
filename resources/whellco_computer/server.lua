local QBCore = exports['qb-core']:GetCoreObject()

local posts = {}
local nextPostId = 1

QBCore.Functions.CreateCallback('whellco_computer:getBankBalance', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        cb(0)
        return
    end

    cb(Player.PlayerData.money.bank or 0)
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