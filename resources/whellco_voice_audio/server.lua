local QBCore = exports['qb-core']:GetCoreObject()

local megaphoneCooldowns = {}

local function getJobRadioChannel(Player)
    local job = Player.PlayerData.job

    if not job then
        return nil
    end

    return Config.RadioChannels[job.name]
end

RegisterNetEvent('whellco_voice_audio:joinJobRadio', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local channel = getJobRadioChannel(Player)

    if not channel then
        TriggerClientEvent('QBCore:Notify', source, 'No job radio channel available.', 'error')
        return
    end

    TriggerClientEvent('whellco_voice_audio:setRadioChannel', source, channel)
    TriggerClientEvent('QBCore:Notify', source, ('Joined job radio channel %d.'):format(channel), 'success')
end)

RegisterNetEvent('whellco_voice_audio:leaveRadio', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    TriggerClientEvent('whellco_voice_audio:setRadioChannel', source, 0)
    TriggerClientEvent('QBCore:Notify', source, 'Left radio channel.', 'primary')
end)

RegisterNetEvent('whellco_voice_audio:megaphone', function(coords)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local now = os.time()

    if now - (megaphoneCooldowns[source] or 0) < Config.Megaphone.cooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before using the megaphone again.', 'error')
        return
    end

    megaphoneCooldowns[source] = now

    TriggerClientEvent('whellco_voice_audio:megaphone', -1, {
        source = source,
        coords = coords,
        range = Config.Megaphone.range,
        volume = Config.Megaphone.volume
    })
end)

RegisterCommand('joinradio', function()
    TriggerEvent('whellco_voice_audio:joinJobRadio')
end, false)

RegisterCommand('leaveradio', function()
    TriggerEvent('whellco_voice_audio:leaveRadio')
end, false)

RegisterCommand('megaphone', function()
    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    TriggerEvent('whellco_voice_audio:megaphone', coords)
end, false)