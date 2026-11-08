local QBCore = exports['qb-core']:GetCoreObject()

local craftCooldowns = {}

local function isNear(coords, location)
    return #(coords - location.location) <= location.radius
end

RegisterNetEvent('whellco_lockpick_crafting:craft', function(recipeId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local recipe = Config.Recipes[recipeId]

    if not Player or not recipe then
        TriggerClientEvent('QBCore:Notify', source, 'Recipe not found.', 'error')
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if not isNear(coords, Config.CraftingLocation) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not at the crafting bench.', 'error')
        return
    end

    local now = os.time()

    if now - (craftCooldowns[source] or 0) < Config.CraftCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before crafting again.', 'error')
        return
    end

    for material, required in pairs(recipe.materials) do
        local item = Player.Functions.GetItemByName(material)

        if not item or item.amount < required then
            TriggerClientEvent('QBCore:Notify', source, ('Missing material: %s.'):format(material), 'error')
            return
        end
    end

    for material, required in pairs(recipe.materials) do
        Player.Functions.RemoveItem(material, required)
    end

    craftCooldowns[source] = now

    TriggerClientEvent('whellco_lockpick_crafting:startCrafting', source, {
        recipeId = recipeId,
        label = recipe.label,
        duration = Config.CraftTime
    })
end)

RegisterNetEvent('whellco_lockpick_crafting:complete', function(recipeId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local recipe = Config.Recipes[recipeId]

    if not Player or not recipe then
        return
    end

    Player.Functions.AddItem(recipeId, recipe.outputAmount)

    TriggerClientEvent('whellco_lockpick_crafting:crafted', source, {
        recipeId = recipeId,
        label = recipe.label,
        amount = recipe.outputAmount
    })
end)

RegisterCommand('craftlockpick', function(source, args)
    local recipeId = args[1]

    if not recipeId then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /craftlockpick [lockpick|advanced_lockpick]', 'error')
        return
    end

    TriggerEvent('whellco_lockpick_crafting:craft', recipeId)
end, false)