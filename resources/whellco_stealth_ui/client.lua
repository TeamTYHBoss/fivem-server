local QBCore = exports['qb-core']:GetCoreObject()

local stealthLevels = {
    [1] = { xpRequired = 0 },
    [2] = { xpRequired = 50 },
    [3] = { xpRequired = 150 }
}

local function updateStealthUi()
    local PlayerData = QBCore.Functions.GetPlayerData()
    local xp = PlayerData.metadata.stealth_xp or 0
    local level = PlayerData.metadata.stealth_level or '1'
    level = tonumber(level) or 1

    local current = stealthLevels[level] or stealthLevels[1]
    local next = stealthLevels[level + 1]
    local requiredXp = next and next.xpRequired or current.xpRequired
    local progress = 100

    if next then
        progress = math.floor(((xp - current.xpRequired) / (next.xpRequired - current.xpRequired)) * 100)
    end

    SendNUIMessage({
        action = 'updateStealth',
        level = level,
        currentXp = xp,
        requiredXp = requiredXp,
        progress = math.max(0, math.min(100, progress))
    })
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    updateStealthUi()
end)

RegisterNetEvent('whellco_stealth_leveling:client:update', function()
    updateStealthUi()
end)

RegisterCommand('stealthui', function()
    updateStealthUi()
end, false)