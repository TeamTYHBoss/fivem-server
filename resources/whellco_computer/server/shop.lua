QBCore.Functions.CreateCallback('whellco_computer:getShop', function(source, cb)
    cb(Config.ShopItems or {})
end)

QBCore.Functions.CreateCallback('whellco_computer:buyItem', function(source, cb, itemId)
    local Player = Computer.GetPlayer(source)

    if not Player or type(itemId) ~= 'string' then
        cb(false, 'Invalid purchase request.')
        return
    end

    if Computer.Cooldown.IsOnCooldown(source) then
        cb(false, 'Please wait before making another purchase.')
        return
    end

    local item = Config.ShopItems and Config.ShopItems[itemId]

    if not item or type(item.price) ~= 'number' or item.price < 0 then
        cb(false, 'That item is not available.')
        return
    end

    if (Player.PlayerData.money.bank or 0) < item.price then
        cb(false, 'You do not have enough money in your bank account.')
        return
    end

    if not Player.Functions.AddItem(itemId, 1) then
        cb(false, 'Your inventory is full.')
        return
    end

    if not Player.Functions.RemoveMoney('bank', item.price, 'computer-shop-purchase') then
        Player.Functions.RemoveItem(itemId, 1)
        cb(false, 'Purchase failed.')
        return
    end

    Computer.Cooldown.SetCooldown(source)
    cb(true, ('Purchased %s.'):format(item.label or itemId))
end)
