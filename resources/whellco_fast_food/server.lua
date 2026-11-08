local QBCore = exports['qb-core']:GetCoreObject()
local MySQL = exports.oxmysql

local function notify(source, message, kind)
    TriggerClientEvent('QBCore:Notify', source, message, kind or 'primary', 5000)
end

local function isAdmin(Player)
    local job = Player.PlayerData.job

    return job and Config.AdminJobs and Config.AdminJobs[job.name] or false
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

    if type(restaurantId) ~= 'string' or type(itemId) ~= 'string' then
        return
    end

    if not canBuy(restaurantId, itemId) then
        notify(source, 'This item is not available here.', 'error')
        return
    end

    local item = Config.Menu[itemId]

    if (Player.PlayerData.money.cash or 0) < item.price then
        notify(source, 'You do not have enough cash.', 'error')
        return
    end

    if not Player.Functions.AddItem(itemId, 1) then
        notify(source, 'Your inventory is full.', 'error')
        return
    end

    if not Player.Functions.RemoveMoney('cash', item.price, 'fast-food-purchase') then
        Player.Functions.RemoveItem(itemId, 1)
        notify(source, 'Purchase failed.', 'error')
        return
    end

    MySQL.insert(
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
    notify(source, ('Purchased %s for $%d.'):format(item.label, item.price), 'success')
end)

RegisterNetEvent('whellco_fast_food:eat', function(itemId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local item = Config.Menu[itemId]

    if not Player or type(itemId) ~= 'string' or not item then
        return
    end

    local inventoryItem = Player.Functions.GetItemByName(itemId)

    if not inventoryItem or (inventoryItem.amount or 0) < 1 then
        notify(source, 'You do not have this food item.', 'error')
        return
    end

    if not Player.Functions.RemoveItem(itemId, 1) then
        notify(source, 'Could not consume that item.', 'error')
        return
    end

    notify(source, ('You ate %s.'):format(item.label), 'success')
end)

RegisterCommand('foodinfo', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isAdmin(Player) then
        return
    end

    notify(source, 'Fast food restaurants are active.', 'primary')
end, false)