local QBCore = exports['qb-core']:GetCoreObject()

local requestCooldowns = {}

local function isDJ(Player)
    local job = Player.PlayerData.job

    return job and job.name == Config.DJJob
end

RegisterNetEvent('whellco_dj_requests:request', function(songId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local now = os.time()

    if now - (requestCooldowns[source] or 0) < Config.RequestCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before requesting another song.', 'error')
        return
    end

    local song = nil

    for _, s in ipairs(Config.Songs) do
        if s.id == tonumber(songId) then
            song = s
            break
        end
    end

    if not song then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid song selected.', 'error')
        return
    end

    if Player.PlayerData.money.cash < Config.RequestPrice then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have enough cash.', 'error')
        return
    end

    Player.Functions.RemoveMoney('cash', Config.RequestPrice, 'dj-song-request')

    requestCooldowns[source] = now

    local players = QBCore.Functions.GetQBPlayers()

    for _, target in pairs(players) do
        if isDJ(target) then
            TriggerClientEvent('whellco_dj_requests:new', target.PlayerData.source, {
                requester = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
                song = song
            })
        end
    end

    TriggerClientEvent('QBCore:Notify', source, ('Song request sent: %s'):format(song.label), 'success')
end)

RegisterCommand('songrequest', function(source, args)
    local songId = args[1]

    if not songId then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /songrequest [song_id]', 'error')
        return
    end

    TriggerEvent('whellco_dj_requests:request', songId)
end, false)