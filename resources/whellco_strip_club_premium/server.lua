local QBCore = exports['qb-core']:GetCoreObject()

local danceCooldowns = {}

local function isDancer(Player)
    local job = Player.PlayerData.job

    return job and job.name == Config.DancerJob
end

RegisterNetEvent('whellco_strip_club_premium:request', function(dancerSource)
    local source = source
    local Customer = QBCore.Functions.GetPlayer(source)
    local Dancer = QBCore.Functions.GetPlayer(tonumber(dancerSource) or 0)

    if not Customer or not Dancer or not isDancer(Dancer) then
        TriggerClientEvent('QBCore:Notify', source, 'That player is not available for a premium dance.', 'error')
        return
    end

    local now = os.time()

    if now - (danceCooldowns[source] or 0) < Config.CooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before requesting another premium dance.', 'error')
        return
    end

    if Customer.PlayerData.money.cash < Config.PremiumDancePrice then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have enough cash.', 'error')
        return
    end

    Customer.Functions.RemoveMoney('cash', Config.PremiumDancePrice, 'premium-dance')
    Dancer.Functions.AddMoney('cash', Config.PremiumDancePrice, 'premium-dance')

    danceCooldowns[source] = now

    TriggerClientEvent('whellco_strip_club_premium:start', Customer.PlayerData.source, {
        dancerSource = Dancer.PlayerData.source,
        duration = Config.PremiumDanceDuration,
        price = Config.PremiumDancePrice
    })

    TriggerClientEvent('whellco_strip_club_premium:start', Dancer.PlayerData.source, {
        customerSource = Customer.PlayerData.source,
        duration = Config.PremiumDanceDuration,
        price = Config.PremiumDancePrice
    })

    TriggerClientEvent('QBCore:Notify', source, ('Premium dance requested for $%s.'):format(Config.PremiumDancePrice), 'success')
end)

RegisterCommand('premiumdance', function(source, args)
    local dancerSource = args[1]

    if not dancerSource then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /premiumdance [dancer_id]', 'error')
        return
    end

    TriggerEvent('whellco_strip_club_premium:request', dancerSource)
end, false)