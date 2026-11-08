local QBCore = exports['qb-core']:GetCoreObject()

local function getStealthXp(Player)
    return Player.PlayerData.metadata.stealth_xp or 0
end

local function getStealthLevel(xp)
    local level = 1

    for candidateLevel, data in pairs(Config.StealthLevels) do
        if xp >= data.xpRequired and candidateLevel > level then
            level = candidateLevel
        end
    end

    return level
end

RegisterNetEvent('whellco_stealth_leveling:addXp', function(amount)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    amount = math.floor(tonumber(amount) or 0)

    if amount <= 0 then
        return
    end

    local currentXp = getStealthXp(Player)
    local newXp = currentXp + amount
    local currentLevel = getStealthLevel(currentXp)
    local newLevel = getStealthLevel(newXp)

    Player.Functions.SetMetaData('stealth_xp', newXp)
    Player.Functions.SetMetaData('stealth_level', tostring(newLevel))

    if newLevel > currentLevel then
        TriggerClientEvent('QBCore:Notify', source, ('Stealth level increased to %d.'):format(newLevel), 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, ('Stealth XP increased to %d.'):format(newXp), 'primary')
    end
end)

RegisterNetEvent('whellco_stealth_leveling:successfulLockpick', function()
    TriggerEvent('whellco_stealth_leveling:addXp', Config.XpPerSuccessfulLockpick)
end)

RegisterNetEvent('whellco_stealth_leveling:failedLockpick', function()
    TriggerEvent('whellco_stealth_leveling:addXp', Config.XpPerFailedLockpick)
end)

RegisterCommand('stealthxp', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local xp = getStealthXp(Player)
    local level = getStealthLevel(xp)
    local nextLevel = Config.StealthLevels[level + 1]

    if nextLevel then
        TriggerClientEvent('QBCore:Notify', source, ('Stealth level %d. XP: %d/%d.'):format(level, xp, nextLevel.xpRequired), 'primary')
    else
        TriggerClientEvent('QBCore:Notify', source, ('Stealth level %d. Maximum level reached.'):format(level), 'success')
    end
end, false)