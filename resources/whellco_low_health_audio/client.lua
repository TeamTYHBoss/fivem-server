local QBCore = exports['qb-core']:GetCoreObject()

local heartbeatActive = false

local function playHeartbeat()
    PlaySoundFrontend(-1, Config.HeartbeatSound, 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
end

CreateThread(function()
    while true do
        Wait(250)

        local health = GetEntityHealth(PlayerPedId())
        local shouldPlay = health > 0 and health <= Config.LowHealthThreshold

        if shouldPlay and not heartbeatActive then
            heartbeatActive = true

            CreateThread(function()
                while heartbeatActive do
                    playHeartbeat()
                    Wait(Config.HeartbeatInterval)
                end
            end)
        elseif not shouldPlay and heartbeatActive then
            heartbeatActive = false
        end
    end
end)

RegisterCommand('heartbeatinfo', function()
    QBCore.Functions.Notify(
        ('Heartbeat cue activates below %d health.'):format(Config.LowHealthThreshold),
        'primary'
    )
end, false)