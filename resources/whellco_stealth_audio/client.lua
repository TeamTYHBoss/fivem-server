local QBCore = exports['qb-core']:GetCoreObject()

local function playSound(soundName)
    PlaySoundFrontend(-1, soundName, 'HUD_AWARDS', true)
    SetFrontendActive(false)
end

RegisterNetEvent('whellco_stealth_audio:xpGained', function(data)
    if not data then
        return
    end

    playSound(Config.Audio.xpGain)

    QBCore.Functions.Notify(
        ('Stealth XP gained: +%d.'):format(data.amount or 0),
        'primary'
    )
end)

RegisterNetEvent('whellco_stealth_audio:levelUp', function(data)
    if not data then
        return
    end

    playSound(Config.Audio.levelUp)

    QBCore.Functions.Notify(
        ('Stealth level increased to %d.'):format(data.level or 1),
        'success'
    )
end)

RegisterCommand('teststealthaudio', function()
    TriggerEvent('whellco_stealth_audio:xpGained', { amount = 10 })
end, false)