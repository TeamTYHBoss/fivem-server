local QBCore = exports['qb-core']:GetCoreObject()

local foodCooldowns = {}

local function isNear(coords, vendor)
    return #(coords - vendor.location) <= vendor.radius
end

RegisterNetEvent('whellco_street_food:order', function(foodId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local now = os.time()

    if now - (foodCooldowns[source] or 0) < Config.StreetFoodVendor.cooldown then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before ordering again.', 'error')
        return
    end

    local food = nil

    for _, f in ipairs(Config.Foods) do
        if f.id == tonumber(foodId) then
            food = f
            break
        end
    end

    if not food then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid food selected.', 'error')
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if not isNear(coords, Config.StreetFoodVendor) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not near the street food vendor.', 'error')
        return
    end

    if Player.PlayerData.money.cash < Config.StreetFoodVendor.price then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have enough cash.', 'error')
        return
    end

    foodCooldowns[source] = now

    TriggerClientEvent('whellco_street_food:start', source, {
        food = food,
        duration = Config.Minigame.duration,
        successThreshold = Config.Minigame.successThreshold
    })
end)

RegisterNetEvent('whellco_street_food:complete', function(foodLabel, rewardItem, score)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    score = tonumber(score) or 0

    if score >= Config.Minigame.successThreshold then
        Player.Functions.RemoveMoney('cash', Config.StreetFoodVendor.price, 'street-food-vendor')
        Player.Functions.AddItem(rewardItem, 1)
        TriggerClientEvent('QBCore:Notify', source, ('Prepared %s.'):format(foodLabel), 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, ('Failed to prepare %s.'):format(foodLabel), 'error')
    end
end)

RegisterCommand('streetfood', function(source, args)
    local foodId = args[1]

    if not foodId then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /streetfood [food_id]', 'error')
        return
    end

    TriggerEvent('whellco_street_food:order', foodId)
end, false)