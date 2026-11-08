QBCore.Functions.CreateCallback('whellco_computer:getShop', function(source, cb)
    cb(Config.Shop or {})
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

    local shopItem = Config.Shop and Config.Shop[itemId]

    if not shopItem or type(shopItem.item) ~= 'string' or type(shopItem.price) ~= 'number' or shopItem.price < 0 then
        cb(false, 'That item is not available.')
        return
    end

    local inventoryItemName = shopItem.item

    if (Player.PlayerData.money.bank or 0) < shopItem.price then
        cb(false, 'You do not have enough money in your bank account.')
        return
    end

    if not Player.Functions.AddItem(inventoryItemName, 1) then
        cb(false, 'Your inventory is full.')
        return
    end

    if not Player.Functions.RemoveMoney('bank', shopItem.price, 'computer-shop-purchase') then
        Player.Functions.RemoveItem(inventoryItemName, 1)
        cb(false, 'Purchase failed.')
        return
    end

    Computer.Cooldown.SetCooldown(source)
    cb(true, ('Purchased %s.'):format(shopItem.label or itemId))
end)
