local QBCore = exports['qb-core']:GetCoreObject()

local function isAdmin(Player)
    local job = Player.PlayerData.job

    return job and Config.AdminJobs[job.name]
end

local function getRestaurant(id)
    for _, restaurant in ipairs(Config.Restaurants) do
        if restaurant.id == id then
            return restaurant
        end
    end

    return nil
end

local function canBuy(restaurantId, itemId)
    local item = Config.Menu[itemId]

    if not item then
        return false
    end

    for _, restaurant in ipairs(item.restaurants) do
        if restaurant == restaurantId then
            return true
        end
    end

    return false
end

RegisterNetEvent('whellco_fast_food:buy', function(restaurantId, itemId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local restaurant = getRestaurant(restaurantId)

    if not Player or not restaurant then
        return
    end

    if not canBuy(restaurantId, itemId) then
        TriggerClientEvent('QBCore:Notify', source, 'This item is not available here.', 'error')
        return
    end

    local item = Config.Menu[itemId]

    if Player.PlayerData.money.cash < item.price then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have enough cash.', 'error')
        return
    end

    Player.Functions.RemoveMoney('cash', item.price, 'fast-food-purchase')
    Player.Functions.AddItem(itemId, 1)

    MySQL.query.await(
        [[INSERT INTO whellco_fast_food_purchases
            (player_citizenid, restaurant_id, item_id, price)
          VALUES (?, ?, ?, ?)]],
        {
            Player.PlayerData.citizenid,
            restaurant.id,
            itemId,
            item.price
        }
    )

    TriggerClientEvent('whellco_fast_food:handOver', source, itemId)
    TriggerClientEvent('QBCore:Notify', source, ('Purchased %s for $%d.'):format(item.label, item.price), 'success')
end)

RegisterNetEvent('whellco_fast_food:eat', function(itemId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local item = Config.Menu[itemId]

    if not Player or not item then
        return
    end

    local inventoryItem = Player.Functions.GetItemByName(itemId)

    if not inventoryItem or inventoryItem.amount < 1 then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have this food item.', 'error')
        return
    end

    Player.Functions.RemoveItem(itemId, 1)

    TriggerClientEvent('QBCore:Notify', source, ('You ate %s.'):format(item.label), 'success')
end)

RegisterCommand('foodinfo', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isAdmin(Player) then
        return
    end

    TriggerClientEvent('QBCore:Notify', source, 'Fast food restaurants are active.', 'primary')
end, false)