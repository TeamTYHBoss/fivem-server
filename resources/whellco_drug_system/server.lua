local QBCore = exports['qb-core']:GetCoreObject()

local saleCooldowns = {}
local craftCooldowns = {}

local function isNearLocation(coords, locations, maxDistance)
    for _, location in ipairs(locations) do
        if #(coords - location) <= maxDistance then
            return true
        end
    end

    return false
end

RegisterNetEvent('whellco_drug_system:craft', function(recipeName, amount)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local recipe = Config.CraftingRecipes[recipeName]

    if not Player or not recipe then
        return
    end

    amount = math.floor(tonumber(amount) or 0)

    if amount <= 0 or amount > 10 then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid crafting amount.', 'error')
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if not isNearLocation(coords, Config.CraftingLocations, 10.0) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not near a crafting location.', 'error')
        return
    end

    local now = os.time()

    if now - (craftCooldowns[source] or 0) < Config.CraftCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before crafting again.', 'error')
        return
    end

    for _, ingredient in ipairs(recipe.ingredients) do
        local required = ingredient.amount * amount
        local item = Player.Functions.GetItemByName(ingredient.item)

        if not item or item.amount < required then
            TriggerClientEvent('QBCore:Notify', source, ('Not enough %s.'):format(ingredient.item), 'error')
            return
        end
    end

    for _, ingredient in ipairs(recipe.ingredients) do
        Player.Functions.RemoveItem(ingredient.item, ingredient.amount * amount)
    end

    Player.Functions.AddItem(recipe.output, recipe.outputAmount * amount)

    craftCooldowns[source] = now

    TriggerClientEvent('QBCore:Notify', source, ('Crafted %dx %s.'):format(recipe.outputAmount * amount, recipe.label), 'success')
end)

RegisterNetEvent('whellco_drug_system:sell', function(itemName, amount)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local priceRange = Config.SellPrices[itemName]

    if not Player or not priceRange then
        return
    end

    amount = math.floor(tonumber(amount) or 0)

    if amount <= 0 or amount > Config.MaxSaleAmount then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid sale amount.', 'error')
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if not isNearLocation(coords, Config.SellZones, 15.0) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not near a sell zone.', 'error')
        return
    end

    local now = os.time()

    if now - (saleCooldowns[source] or 0) < Config.SaleCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before selling again.', 'error')
        return
    end

    local item = Player.Functions.GetItemByName(itemName)

    if not item or item.amount < amount then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough items to sell.', 'error')
        return
    end

    local unitPrice = math.random(priceRange.min, priceRange.max)
    local total = unitPrice * amount

    Player.Functions.RemoveItem(itemName, amount)
    Player.Functions.AddMoney('cash', total, 'Drug sale')

    saleCooldowns[source] = now

    TriggerClientEvent('QBCore:Notify', source, ('Sold %dx %s for $%d.'):format(amount, itemName, total), 'success')
end)

RegisterCommand('drugcraft', function(source, args)
    local recipeName = args[1]
    local amount = tonumber(args[2]) or 1

    if not recipeName then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /drugcraft [recipe] [amount]', 'error')
        return
    end

    TriggerEvent('whellco_drug_system:craft', recipeName, amount)
end, false)

RegisterCommand('drugsell', function(source, args)
    local itemName = args[1]
    local amount = tonumber(args[2]) or 1

    if not itemName then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /drugsell [item] [amount]', 'error')
        return
    end

    TriggerEvent('whellco_drug_system:sell', itemName, amount)
end, false)