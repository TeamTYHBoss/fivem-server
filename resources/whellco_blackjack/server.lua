local QBCore = exports['qb-core']:GetCoreObject()

local betCooldowns = {}

local function calculateHandValue(cards)
    local total = 0
    local aces = 0

    for _, card in ipairs(cards) do
        if card.rank == 'A' then
            aces = aces + 1
            total = total + 11
        elseif card.rank == 'K' or card.rank == 'Q' or card.rank == 'J' or card.rank == '10' then
            total = total + 10
        else
            total = total + tonumber(card.rank)
        end
    end

    while total > 21 and aces > 0 do
        total = total - 10
        aces = aces - 1
    end

    return total
end

local function drawCard()
    local ranks = {'2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'}
    local suits = {'hearts', 'diamonds', 'clubs', 'spades'}

    return {
        rank = ranks[math.random(#ranks)],
        suit = suits[math.random(#suits)]
    }
end

RegisterNetEvent('whellco_blackjack:play', function(bet)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    bet = tonumber(bet) or 0

    if bet < Config.BlackjackTable.minimumBet or bet > Config.BlackjackTable.maximumBet then
        TriggerClientEvent('QBCore:Notify', source, ('Bet must be between $%s and $%s.'):format(Config.BlackjackTable.minimumBet, Config.BlackjackTable.maximumBet), 'error')
        return
    end

    local now = os.time()

    if now - (betCooldowns[source] or 0) < Config.BlackjackTable.cooldown then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before playing another hand.', 'error')
        return
    end

    if Player.PlayerData.money.cash < bet then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have enough cash.', 'error')
        return
    end

    betCooldowns[source] = now

    local playerCards = {drawCard(), drawCard()}
    local dealerCards = {drawCard(), drawCard()}

    local playerTotal = calculateHandValue(playerCards)
    local dealerTotal = calculateHandValue(dealerCards)

    local result = 'lose'

    if playerTotal > 21 then
        result = 'bust'
    elseif dealerTotal > 21 or playerTotal > dealerTotal then
        result = 'win'
    elseif playerTotal == dealerTotal then
        result = 'push'
    end

    local payout = 0

    if result == 'win' then
        payout = bet * 2
    elseif result == 'push' then
        payout = bet
    end

    if payout > 0 then
        Player.Functions.AddMoney('cash', payout, 'blackjack-payout')
    end

    TriggerClientEvent('whellco_blackjack:result', source, {
        bet = bet,
        playerCards = playerCards,
        dealerCards = dealerCards,
        playerTotal = playerTotal,
        dealerTotal = dealerTotal,
        result = result,
        payout = payout
    })
end)

RegisterCommand('blackjack', function(source, args)
    local bet = args[1]

    if not bet then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /blackjack [bet]', 'error')
        return
    end

    TriggerEvent('whellco_blackjack:play', bet)
end, false)