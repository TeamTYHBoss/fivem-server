local QBCore = exports['qb-core']:GetCoreObject()

local minigameCooldowns = {}

local function isNear(coords, location, radius)
    return #(coords - location) <= radius
end

RegisterNetEvent('whellco_minigames:coffee', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local now = os.time()

    if now - (minigameCooldowns[source] or 0) < 10 then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before buying another coffee.', 'error')
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if not isNear(coords, Config.CoffeeVendor.location, Config.CoffeeVendor.radius) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not near the coffee vendor.', 'error')
        return
    end

    if Player.PlayerData.money.cash < Config.CoffeeVendor.price then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have enough cash.', 'error')
        return
    end

    Player.Functions.RemoveMoney('cash', Config.CoffeeVendor.price, 'coffee-vendor')
    Player.Functions.AddItem(Config.CoffeeVendor.reward, 1)

    minigameCooldowns[source] = now

    TriggerClientEvent('whellco_minigames:coffee', source, {
        label = Config.CoffeeVendor.label,
        reward = Config.CoffeeVendor.reward
    })
end)

RegisterNetEvent('whellco_minigames:complete', function(gameType, score)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local game = Config[gameType]

    if not game then
        return
    end

    score = tonumber(score) or 0

    if score >= game.successThreshold then
        Player.Functions.AddItem(game.reward, 1)
        TriggerClientEvent('QBCore:Notify', source, ('Completed %s.'):format(game.label), 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, ('Failed %s.'):format(game.label), 'error')
    end
end)

RegisterCommand('coffee', function(source)
    TriggerEvent('whellco_minigames:coffee')
end, false)

RegisterCommand('lockpickgame', function(source)
    TriggerClientEvent('whellco_minigames:start', source, 'Lockpick')
end, false)

RegisterCommand('hackgame', function(source)
    TriggerClientEvent('whellco_minigames:start', source, 'Hack')
end, false)

RegisterCommand('repairgame', function(source)
    TriggerClientEvent('whellco_minigames:start', source, 'Repair')
end, false)