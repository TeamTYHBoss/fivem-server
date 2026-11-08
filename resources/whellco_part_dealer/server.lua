local QBCore = exports['qb-core']:GetCoreObject()

local saleCooldowns = {}

local function isNear(coords, dealer)
    return #(coords - dealer.location) <= dealer.radius
end

RegisterNetEvent('whellco_part_dealer:sell', function(partType, amount)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local price = Config.PartPrices[partType]

    if not Player or not price then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid part type.', 'error')
        return
    end

    amount = math.floor(tonumber(amount) or 0)

    if amount <= 0 or amount > Config.MaxPartsPerSale then
        TriggerClientEvent('QBCore:Notify', source, ('Sell between 1 and %d part(s).'):format(Config.MaxPartsPerSale), 'error')
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if not isNear(coords, Config.PartDealer) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not at the part dealer.', 'error')
        return
    end

    local now = os.time()

    if now - (saleCooldowns[source] or 0) < Config.SaleCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before selling more parts.', 'error')
        return
    end

    if Player.Functions.GetItemByName(partType) == nil then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have this part.', 'error')
        return
    end

    local item = Player.Functions.GetItemByName(partType)

    if item.amount < amount then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough parts.', 'error')
        return
    end

    local total = price * amount

    Player.Functions.RemoveItem(partType, amount)
    Player.Functions.AddMoney('cash', total, ('Part dealer sale: %s'):format(partType))

    saleCooldowns[source] = now

    TriggerClientEvent('whellco_part_dealer:sold', source, {
        partType = partType,
        amount = amount,
        total = total
    })

    TriggerClientEvent('QBCore:Notify', source, ('Sold %dx %s for %s%d.'):format(amount, partType, Config.CurrencySymbol, total), 'success')
end)

RegisterNetEvent('whellco_part_dealer:sellScrap', function(amount)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local bonus = Config.BonusItems.scrapmetal

    if not Player or not bonus then
        return
    end

    amount = math.floor(tonumber(amount) or 0)

    if amount <= 0 or amount > bonus.maxAmount then
        TriggerClientEvent('QBCore:Notify', source, ('Sell between 1 and %d scrap.'):format(bonus.maxAmount), 'error')
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if not isNear(coords, Config.PartDealer) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not at the part dealer.', 'error')
        return
    end

    local scrap = Player.Functions.GetItemByName('scrapmetal')

    if not scrap or scrap.amount < amount then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough scrap metal.', 'error')
        return
    end

    local total = bonus.price * amount

    Player.Functions.RemoveItem('scrapmetal', amount)
    Player.Functions.AddMoney('cash', total, 'Scrap metal sale')

    TriggerClientEvent('whellco_part_dealer:sold', source, {
        partType = 'scrapmetal',
        amount = amount,
        total = total
    })

    TriggerClientEvent('QBCore:Notify', source, ('Sold %dx scrap metal for %s%d.'):format(amount, Config.CurrencySymbol, total), 'success')
end)

RegisterCommand('sellpart', function(source, args)
    local partType = args[1]
    local amount = tonumber(args[2])

    if not partType or not amount then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /sellpart [part_type] [amount]', 'error')
        return
    end

    TriggerEvent('whellco_part_dealer:sell', partType, amount)
end, false)

RegisterCommand('sellscrap', function(source, args)
    local amount = tonumber(args[1])

    if not amount then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /sellscrap [amount]', 'error')
        return
    end

    TriggerEvent('whellco_part_dealer:sellScrap', amount)
end, false)