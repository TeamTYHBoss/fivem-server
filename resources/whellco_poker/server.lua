local QBCore = exports['qb-core']:GetCoreObject()

local handCooldowns = {}

local function getRankValue(rank)
    local values = {
        ['2'] = 2, ['3'] = 3, ['4'] = 4, ['5'] = 5,
        ['6'] = 6, ['7'] = 7, ['8'] = 8, ['9'] = 9,
        ['10'] = 10, ['J'] = 11, ['Q'] = 12, ['K'] = 13, ['A'] = 14
    }

    return values[rank] or 0
end

local function evaluateHand(cards)
    local ranks = {}
    local suits = {}

    for _, card in ipairs(cards) do
        ranks[card.rank] = (ranks[card.rank] or 0) + 1
        suits[card.suit] = (suits[card.suit] or 0) + 1
    end

    local pairs = 0
    local hasThree = false

    for _, count in pairs(ranks) do
        if count == 2 then
            pairs = pairs + 1
        elseif count == 3 then
            hasThree = true
        end
    end

    if pairs == 2 then
        return 'Two Pair'
    elseif hasThree and pairs == 1 then
        return 'Full House'
    elseif hasThree then
        return 'Three of a Kind'
    elseif pairs == 1 then
        return 'One Pair'
    end

    return 'High Card'
end

RegisterNetEvent('whellco_poker:play', function(bet)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    bet = tonumber(bet) or 0

    if bet < Config.PokerTable.minimumBet or bet > Config.PokerTable.maximumBet then
        TriggerClientEvent('QBCore:Notify', source, ('Bet must be between $%s and $%s.'):format(Config.PokerTable.minimumBet, Config.PokerTable.maximumBet), 'error')
        return
    end

    local now = os.time()

    if now - (handCooldowns[source] or 0) < Config.PokerTable.cooldown then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before playing another hand.', 'error')
        return
    end

    if Player.PlayerData.money.cash < bet then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have enough cash.', 'error')
        return
    end

    handCooldowns[source] = now

    local ranks = {'2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'}
    local suits = {'hearts', 'diamonds', 'clubs', 'spades'}

    local playerCards = {}
    local dealerCards = {}

    for i = 1, 5 do
        playerCards[i] = {
            rank = ranks[math.random(#ranks)],
            suit = suits[math.random(#suits)]
        }

        dealerCards[i] = {
            rank = ranks[math.random(#ranks)],
            suit = suits[math.random(#suits)]
        }
    end

    local playerHand = evaluateHand(playerCards)
    local dealerHand = evaluateHand(dealerCards)

    local result = 'lose'

    if playerHand == dealerHand then
        result = 'push'
    elseif playerHand == 'Full House' or (playerHand == 'Three of a Kind' and dealerHand ~= 'Full House') or (playerHand == 'Two Pair' and dealerHand == 'One Pair') then
        result = 'win'
    end

    local payout = result == 'win' and bet * 2 or result == 'push' and bet or 0

    if payout > 0 then
        Player.Functions.AddMoney('cash', payout, 'poker-payout')
    end

    TriggerClientEvent('whellco_poker:result', source, {
        bet = bet,
        playerCards = playerCards,
        dealerCards = dealerCards,
        playerHand = playerHand,
        dealerHand = dealerHand,
        result = result,
        payout = payout
    })
end)

RegisterCommand('poker', function(source, args)
    local bet = args[1]

    if not bet then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /poker [bet]', 'error')
        return
    end

    TriggerEvent('whellco_poker:play', bet)
end, false)