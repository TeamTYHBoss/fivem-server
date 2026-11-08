local QBCore = exports['qb-core']:GetCoreObject()

local betCooldowns = {}

local function getColor(number)
    if number == 0 then
        return 'green'
    end

    local redNumbers = {1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36}

    for _, red in ipairs(redNumbers) do
        if red == number then
            return 'red'
        end
    end

    return 'black'
end

RegisterNetEvent('whellco_roulette:play', function(betType, betValue, bet)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    bet = tonumber(bet) or 0

    if bet < Config.RouletteTable.minimumBet or bet > Config.RouletteTable.maximumBet then
        TriggerClientEvent('QBCore:Notify', source, ('Bet must be between $%s and $%s.'):format(Config.RouletteTable.minimumBet, Config.RouletteTable.maximumBet), 'error')
        return
    end

    local now = os.time()

    if now - (betCooldowns[source] or 0) < Config.RouletteTable.cooldown then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before placing another bet.', 'error')
        return
    end

    if Player.PlayerData.money.cash < bet then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have enough cash.', 'error')
        return
    end

    betCooldowns[source] = now

    local number = math.random(0, 36)
    local color = getColor(number)
    local parity = number == 0 and 'none' or (number % 2 == 0 and 'even' or 'odd')

    local won = false
    local multiplier = 0

    if betType == 'number' and tonumber(betValue) == number then
        won = true
        multiplier = Config.Payouts.number
    elseif betType == 'color' and betValue == color then
        won = true
        multiplier = Config.Payouts.color
    elseif betType == 'parity' and betValue == parity then
        won = true
        multiplier = Config.Payouts.parity
    end

    local payout = won and bet * (multiplier + 1) or 0

    if payout > 0 then
        Player.Functions.AddMoney('cash', payout, 'roulette-payout')
    end

    TriggerClientEvent('whellco_roulette:result', source, {
        betType = betType,
        betValue = betValue,
        bet = bet,
        number = number,
        color = color,
        parity = parity,
        won = won,
        payout = payout
    })
end)

RegisterCommand('roulette', function(source, args)
    local betType = args[1]
    local betValue = args[2]
    local bet = args[3]

    if not betType or not betValue or not bet then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /roulette [number|color|parity] [value] [bet]', 'error')
        return
    end

    TriggerEvent('whellco_roulette:play', betType, betValue, bet)
end, false)