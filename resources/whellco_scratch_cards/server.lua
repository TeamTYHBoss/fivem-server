local QBCore = exports['qb-core']:GetCoreObject()

local scratchCooldowns = {}

RegisterNetEvent('whellco_scratch_cards:scratch', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local now = os.time()

    if now - (scratchCooldowns[source] or 0) < Config.ScratchCard.cooldown then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before scratching another card.', 'error')
        return
    end

    if not Player.Functions.RemoveItem(Config.ScratchCard.item, 1) then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have a scratch card.', 'error')
        return
    end

    scratchCooldowns[source] = now

    local roll = math.random(1, 100)
    local cumulative = 0
    local payout = 0

    for _, prize in ipairs(Config.Prizes) do
        cumulative = cumulative + prize.chance

        if roll <= cumulative then
            payout = prize.payout
            break
        end
    end

    if payout > 0 then
        Player.Functions.AddMoney('cash', payout, 'scratch-card-payout')
    end

    TriggerClientEvent('whellco_scratch_cards:result', source, {
        card = Config.ScratchCard.label,
        payout = payout,
        won = payout > 0
    })
end)

RegisterCommand('scratch', function(source)
    TriggerEvent('whellco_scratch_cards:scratch')
end, false)