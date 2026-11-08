local QBCore = exports['qb-core']:GetCoreObject()

local function getStealthLevel(Player)
    local level = Player.PlayerData.metadata.stealth_level or 'none'

    return Config.StealthLevels[level] or Config.StealthLevels.none
end

RegisterNetEvent('whellco_stealth_perk:checkAlert', function(coords)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local stealth = getStealthLevel(Player)
    local alertChance = math.max(
        Config.MinimumAlertChance,
        Config.BaseAlertChance - stealth.reduction
    )

    local alertTriggered = math.random(1, 100) <= alertChance

    TriggerClientEvent('whellco_stealth_perk:alertResult', source, {
        alertTriggered = alertTriggered,
        alertChance = alertChance,
        stealthLevel = stealth.label
    })

    if alertTriggered then
        TriggerEvent('whellco_lockpick_alerts:failed', coords, 'lockpick')
    end
end)

RegisterCommand('stealthinfo', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local stealth = getStealthLevel(Player)
    local alertChance = math.max(
        Config.MinimumAlertChance,
        Config.BaseAlertChance - stealth.reduction
    )

    TriggerClientEvent('QBCore:Notify', source, ('%s. Alert chance: %d%%.'):format(stealth.label, alertChance), 'primary')
end, false)