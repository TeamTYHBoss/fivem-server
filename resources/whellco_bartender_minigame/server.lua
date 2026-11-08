local QBCore = exports['qb-core']:GetCoreObject()

local mixCooldowns = {}

local function isBartender(Player)
    local job = Player.PlayerData.job

    return job and job.name == Config.BartenderJob
end

RegisterNetEvent('whellco_bartender_minigame:start', function(drinkIndex)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isBartender(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not authorised to mix drinks.', 'error')
        return
    end

    local now = os.time()

    if now - (mixCooldowns[source] or 0) < Config.MixCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before mixing another drink.', 'error')
        return
    end

    local drink = Config.Drinks[tonumber(drinkIndex) or 0]

    if not drink then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid drink selected.', 'error')
        return
    end

    mixCooldowns[source] = now

    TriggerClientEvent('whellco_bartender_minigame:start', source, {
        drink = drink,
        duration = Config.MinigameDuration,
        successThreshold = Config.SuccessThreshold
    })
end)

RegisterNetEvent('whellco_bartender_minigame:complete', function(drinkLabel, score)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isBartender(Player) then
        return
    end

    score = tonumber(score) or 0

    local success = score >= Config.SuccessThreshold

    if success then
        Player.Functions.AddItem('cocktail', 1)
        TriggerClientEvent('QBCore:Notify', source, ('Successfully mixed %s.'):format(drinkLabel), 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, ('Failed to mix %s.'):format(drinkLabel), 'error')
    end
end)

RegisterCommand('mixdrink', function(source, args)
    local drinkIndex = args[1]

    if not drinkIndex then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /mixdrink [drink_id]', 'error')
        return
    end

    TriggerEvent('whellco_bartender_minigame:start', drinkIndex)
end, false)