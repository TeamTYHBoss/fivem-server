local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_dj_requests:new', function(data)
    if not data then
        return
    end

    QBCore.Functions.Notify(
        ('New song request: %s by %s'):format(data.song.label, data.requester),
        'primary',
        10000
    )
end)

RegisterCommand('songrequestinfo', function()
    QBCore.Functions.Notify('Use /songrequest [song_id] to request a song at the DJ booth.', 'primary')
end, false)