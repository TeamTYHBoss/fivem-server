local QBCore = exports['qb-core']:GetCoreObject()

local tipCooldowns = {}

local function isDancer(Player)
    local job = Player.PlayerData.job

    return job and job.name == Config.DancerJob
end

RegisterNetEvent('whellco_dancer_tip_jar:tip', function(dancerSource, amount)
    local source = source
    local Customer = QBCore.Functions.GetPlayer(source)
    local Dancer = QBCore.Functions.GetPlayer(tonumber(dancerSource) or 0)

    if not Customer or not Dancer or not isDancer(Dancer) then
        TriggerClientEvent('QBCore:Notify', source, 'That player is not an available dancer.', 'error')
        return
    end

    amount = tonumber(amount) or 0

    if amount < Config.MinimumTip or amount > Config.MaximumTip then
        TriggerClientEvent('QBCore:Notify', source, ('Tip must be between $%s and $%s.'):format(Config.MinimumTip, Config.MaximumTip), 'error')
        return
    end

    local now = os.time()

    if now - (tipCooldowns[source] or 0) < Config.TipCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before tipping again.', 'error')
        return
    end

    if Customer.PlayerData.money.cash < amount then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have enough cash.', 'error')
        return
    end

    Customer.Functions.RemoveMoney('cash', amount, 'dancer-tip')
    Dancer.Functions.AddMoney('cash', amount, 'dancer-tip')

    tipCooldowns[source] = now

    TriggerClientEvent('QBCore:Notify', source, ('Tipped $%s.'):format(amount), 'success')
    TriggerClientEvent('QBCore:Notify', Dancer.PlayerData.source, ('Received a $%s tip.'):format(amount), 'success')
end)

RegisterCommand('tip', function(source, args)
    local dancerSource = args[1]
    local amount = args[2]

    if not dancerSource or not amount then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /tip [dancer_id] [amount]', 'error')
        return
    end

    TriggerEvent('whellco_dancer_tip_jar:tip', dancerSource, amount)
end, false)