local QBCore = exports['qb-core']:GetCoreObject()

local purchaseCooldowns = {}
local launderCooldowns = {}

local function isPolice(Player)
    local job = Player.PlayerData.job

    return job and Config.AllowedJobs[job.name]
end

local function isNear(coords, target, distance)
    return #(coords - target) <= distance
end

RegisterNetEvent('whellco_blackmarket:purchase', function(itemName, amount)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local item = Config.BlackMarket.items[itemName]

    if not Player or not item then
        return
    end

    amount = math.floor(tonumber(amount) or 0)

    if amount <= 0 or amount > item.stock then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid purchase amount.', 'error')
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if not isNear(coords, Config.BlackMarket.location, 10.0) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not near the black market.', 'error')
        return
    end

    local now = os.time()

    if now - (purchaseCooldowns[source] or 0) < Config.CooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before purchasing again.', 'error')
        return
    end

    local total = item.price * amount

    if Player.Functions.GetMoney('cash') < total then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough cash.', 'error')
        return
    end

    Player.Functions.RemoveMoney('cash', total, ('Black market purchase: %s'):format(itemName))
    Player.Functions.AddItem(itemName, amount)

    purchaseCooldowns[source] = now

    TriggerClientEvent('QBCore:Notify', source, ('Purchased %dx %s for $%d.'):format(amount, itemName, total), 'success')
end)

RegisterNetEvent('whellco_blackmarket:launder', function(amount)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    amount = math.floor(tonumber(amount) or 0)

    if amount < Config.Laundering.minAmount or amount > Config.Laundering.maxAmount then
        TriggerClientEvent('QBCore:Notify', source, ('Launder between %s%d and %s%d.'):format(Config.CurrencySymbol, Config.Laundering.minAmount, Config.CurrencySymbol, Config.Laundering.maxAmount), 'error')
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if not isNear(coords, Config.Laundering.location, 10.0) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not near the laundering location.', 'error')
        return
    end

    local now = os.time()

    if now - (launderCooldowns[source] or 0) < Config.Laundering.cooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before laundering again.', 'error')
        return
    end

    if Player.Functions.GetMoney('cash') < amount then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough cash to launder.', 'error')
        return
    end

    local fee = math.floor(amount * (Config.LaunderFeePercent / 100))
    local cleanAmount = amount - fee

    Player.Functions.RemoveMoney('cash', amount, 'Money laundering')
    Player.Functions.AddMoney('bank', cleanAmount, 'Laundered money')

    launderCooldowns[source] = now

    TriggerClientEvent('QBCore:Notify', source, ('Laundered %s%d into %s%d after fees.'):format(Config.CurrencySymbol, amount, Config.CurrencySymbol, cleanAmount), 'success')
end)

RegisterCommand('blackmarket', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local items = {}

    for itemName, item in pairs(Config.BlackMarket.items) do
        items[#items + 1] = ('%s - $%d'):format(itemName, item.price)
    end

    TriggerClientEvent('QBCore:Notify', source, table.concat(items, ', '), 'primary')
end, false)

RegisterCommand('launder', function(source, args)
    local amount = tonumber(args[1])

    if not amount then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /launder [amount]', 'error')
        return
    end

    TriggerEvent('whellco_blackmarket:launder', amount)
end, false)