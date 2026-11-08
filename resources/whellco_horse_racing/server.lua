local QBCore = exports['qb-core']:GetCoreObject()

local raceCooldowns = {}

local function isNear(coords, track)
    return #(coords - track.location) <= track.radius
end

RegisterNetEvent('whellco_horse_racing:bet', function(horseId, bet)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    bet = tonumber(bet) or 0

    if bet < Config.RacingTrack.minimumBet or bet > Config.RacingTrack.maximumBet then
        TriggerClientEvent('QBCore:Notify', source, ('Bet must be between $%s and $%s.'):format(Config.RacingTrack.minimumBet, Config.RacingTrack.maximumBet), 'error')
        return
    end

    local now = os.time()

    if now - (raceCooldowns[source] or 0) < Config.RacingTrack.cooldown then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before placing another bet.', 'error')
        return
    end

    local horse = nil

    for _, h in ipairs(Config.Horses) do
        if h.id == tonumber(horseId) then
            horse = h
            break
        end
    end

    if not horse then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid horse selected.', 'error')
        return
    end

    if Player.PlayerData.money.cash < bet then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have enough cash.', 'error')
        return
    end

    raceCooldowns[source] = now

    local winnerId = math.random(#Config.Horses)
    local won = horse.id == winnerId
    local payout = won and bet * horse.odds or 0

    if payout > 0 then
        Player.Functions.AddMoney('cash', payout, 'horse-racing-payout')
    end

    TriggerClientEvent('whellco_horse_racing:result', source, {
        horse = horse,
        bet = bet,
        winnerId = winnerId,
        won = won,
        payout = payout
    })
end)

RegisterCommand('horsebet', function(source, args)
    local horseId = args[1]
    local bet = args[2]

    if not horseId or not bet then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /horsebet [horse_id] [bet]', 'error')
        return
    end

    TriggerEvent('whellco_horse_racing:bet', horseId, bet)
end, false)