local QBCore = exports['qb-core']:GetCoreObject()

local tipCooldowns = {}

local function isNear(coords, location)
    return #(coords - location.location) <= location.radius
end

RegisterNetEvent('whellco_strip_club:buyDrink', function(drinkType)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local drink = Config.Drinks[drinkType]

    if not Player or not drink then
        TriggerClientEvent('QBCore:Notify', source, 'Drink not found.', 'error')
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if not isNear(coords, Config.StripClub) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not at the strip club.', 'error')
        return
    end

    if Player.Functions.GetMoney('cash') < drink.price then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough cash.', 'error')
        return
    end

    Player.Functions.RemoveMoney('cash', drink.price, ('Strip club drink: %s'):format(drinkType))
    Player.Functions.AddItem(drinkType, 1)

    TriggerClientEvent('QBCore:Notify', source, ('Purchased %s for %s%d.'):format(drink.label, Config.CurrencySymbol, drink.price), 'success')
end)

RegisterNetEvent('whellco_strip_club:tip', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local now = os.time()

    if now - (tipCooldowns[source] or 0) < Config.TipCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before tipping again.', 'error')
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if not isNear(coords, Config.StripClub) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not at the strip club.', 'error')
        return
    end

    if Player.Functions.GetMoney('cash') < Config.TipAmount then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough cash.', 'error')
        return
    end

    Player.Functions.RemoveMoney('cash', Config.TipAmount, 'Strip club tip')

    tipCooldowns[source] = now

    TriggerClientEvent('QBCore:Notify', source, ('Tipped %s%d.'):format(Config.CurrencySymbol, Config.TipAmount), 'success')
end)

RegisterCommand('stripclub', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local drinks = {}

    for drinkType, drink in pairs(Config.Drinks) do
        drinks[#drinks + 1] = ('%s - %s%d'):format(drinkType, Config.CurrencySymbol, drink.price)
    end

    TriggerClientEvent('QBCore:Notify', source, table.concat(drinks, ', '), 'primary')
end, false)

RegisterCommand('tipdancer', function()
    TriggerEvent('whellco_strip_club:tip')
end, false)