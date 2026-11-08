local QBCore = exports['qb-core']:GetCoreObject()

local distortionBoost = 0.0
local lastHealth = 0

local function updateDistortion()
    local playerPed = PlayerPedId()
    local health = GetEntityHealth(playerPed)
    local damage = math.max(0, lastHealth - health)

    if damage >= Config.DamageThreshold then
        distortionBoost = math.min(
            Config.MaxDistortion,
            distortionBoost + (damage / 100) * Config.DamageBoost
        )
    end

    lastHealth = health

    SendNUIMessage({
        action = 'addDamageDistortion',
        intensity = distortionBoost
    })
end

CreateThread(function()
    lastHealth = GetEntityHealth(PlayerPedId())

    while true do
        Wait(Config.UpdateInterval)

        updateDistortion()

        if distortionBoost > 0 then
            distortionBoost = math.max(0, distortionBoost - Config.DecayPerSecond)
        end
    end
end)

RegisterCommand('damageinfo', function()
    QBCore.Functions.Notify('Taking damage increases visual distortion temporarily.', 'primary')
end, false)