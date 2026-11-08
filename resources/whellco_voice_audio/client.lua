local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_voice_audio:setRadioChannel', function(channel)
    if not channel then
        return
    end

    exports['pma-voice']:setRadioChannel(channel)
end)

RegisterNetEvent('whellco_voice_audio:megaphone', function(data)
    if not data or not data.coords then
        return
    end

    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = #(playerCoords - data.coords)

    if distance <= data.range then
        QBCore.Functions.Notify('Megaphone announcement nearby.', 'primary')
    end
end)

RegisterCommand('voiceinfo', function()
    QBCore.Functions.Notify(
        ('Voice system: %s. Use /joinradio, /leaveradio, and /megaphone.'):format(Config.VoiceSystem),
        'primary'
    )
end, false)