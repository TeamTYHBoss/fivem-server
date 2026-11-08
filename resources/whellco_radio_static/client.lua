local QBCore = exports['qb-core']:GetCoreObject()

local radioEnabled = false
local lastToggle = 0

local function playStatic()
    PlaySoundFrontend(-1, Config.StaticSound, 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
end

local function toggleRadio()
    local now = GetGameTimer()

    if now - lastToggle < Config.ToggleCooldownSeconds * 1000 then
        return
    end

    lastToggle = now
    radioEnabled = not radioEnabled

    if radioEnabled then
        local PlayerData = QBCore.Functions.GetPlayerData()
        local channel = Config.RadioChannels[PlayerData.job.name]

        if channel then
            exports['pma-voice']:setRadioChannel(channel)
        end

        playStatic()
        QBCore.Functions.Notify('Radio enabled.', 'success')
    else
        exports['pma-voice']:setRadioChannel(0)
        playStatic()
        QBCore.Functions.Notify('Radio disabled.', 'primary')
    end
end

CreateThread(function()
    while true do
        Wait(0)

        if IsControlJustPressed(0, Config.StaticToggleKey) then
            toggleRadio()
        end
    end
end)

RegisterCommand('radiostatic', function()
    toggleRadio()
end, false)

RegisterCommand('radiostaticinfo', function()
    QBCore.Functions.Notify('Press Y or use /radiostatic to toggle the radio with static effects.', 'primary')
end, false)