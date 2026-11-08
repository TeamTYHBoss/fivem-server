local QBCore = exports['qb-core']:GetCoreObject()

local muffled = false

local function setMuffled(enabled)
    if enabled == muffled then
        return
    end

    muffled = enabled

    local targetVolume = enabled and Config.MuffledVolume or Config.NormalVolume

    SetAudioFlag('PlayerSpeechMuffled', enabled)
    SetAudioFlag('PlayerSpeechMuffled', enabled)
    SetFrontendActive(false)

    QBCore.Functions.Notify(
        enabled and 'Audio muffled due to critical health.' or 'Audio restored.',
        enabled and 'error' or 'success'
    )
end

CreateThread(function()
    while true do
        Wait(Config.CheckInterval)

        local health = GetEntityHealth(PlayerPedId())
        local shouldMuffle = health > 0 and health <= Config.CriticalHealthThreshold

        setMuffled(shouldMuffle)
    end
end)

RegisterCommand('criticalaudioinfo', function()
    QBCore.Functions.Notify(
        ('Game audio is muffled below %d health.'):format(Config.CriticalHealthThreshold),
        'primary'
    )
end, false)