local QBCore = exports['qb-core']:GetCoreObject()

local heartbeatActive = false

local function getBeatInterval(health)
    local threshold = Config.LowHealthThreshold
    local progress = math.max(0, math.min(1, health / threshold))

    return math.floor(Config.FastBeatInterval + progress * (Config.SlowBeatInterval - Config.FastBeatInterval))
end

CreateThread(function()
    while true do
        Wait(Config.CheckInterval)

        local playerPed = PlayerPedId()
        local health = GetEntityHealth(playerPed)
        local shouldPlay = health > 0 and health <= Config.LowHealthThreshold

        if shouldPlay and not heartbeatActive then
            heartbeatActive = true

            CreateThread(function()
                while heartbeatActive do
                    local currentHealth = GetEntityHealth(PlayerPedId())
                    local interval = getBeatInterval(currentHealth)

                    PlaySoundFrontend(-1, Config.HeartbeatSound, 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
                    Wait(interval)
                end
            end)
        elseif not shouldPlay and heartbeatActive then
            heartbeatActive = false
        end
    end
end)

RegisterCommand('dynamicheartbeatinfo', function()
    QBCore.Functions.Notify(
        ('Heartbeat speeds up as health drops below %d.'):format(Config.LowHealthThreshold),
        'primary'
    )
end, false)