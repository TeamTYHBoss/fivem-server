local QBCore = exports['qb-core']:GetCoreObject()

local intoxication = {}

local function getQuality(score)
    if score >= Config.QualityThresholds.excellent then
        return 'excellent'
    elseif score >= Config.QualityThresholds.good then
        return 'good'
    else
        return 'poor'
    end
end

RegisterNetEvent('whellco_drink_intoxication_link:consume', function(targetSource, score)
    local source = source
    local Bartender = QBCore.Functions.GetPlayer(source)
    local Target = QBCore.Functions.GetPlayer(tonumber(targetSource) or 0)

    if not Bartender or not Target or not Bartender.PlayerData.job.name == Config.BartenderJob then
        TriggerClientEvent('QBCore:Notify', source, 'You are not authorised to serve drinks.', 'error')
        return
    end

    score = tonumber(score) or 0

    local quality = getQuality(score)
    local gain = Config.IntoxicationGain[quality]
    local citizenid = Target.PlayerData.citizenid

    intoxication[citizenid] = math.min(
        Config.MaxIntoxication,
        (intoxication[citizenid] or 0) + gain
    )

    TriggerClientEvent('whellco_drink_intoxication_link:consumed', Target.PlayerData.source, {
        quality = quality,
        intoxication = intoxication[citizenid]
    })

    TriggerClientEvent('QBCore:Notify', source, ('Drink quality: %s. Intoxication increased.'):format(quality), 'success')
end)

RegisterCommand('drinkquality', function(source, args)
    local targetSource = args[1]
    local score = args[2]

    if not targetSource or not score then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /drinkquality [player_id] [score]', 'error')
        return
    end

    TriggerEvent('whellco_drink_intoxication_link:consume', targetSource, score)
end, false)