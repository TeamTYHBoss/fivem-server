local QBCore = exports['qb-core']:GetCoreObject()
local MySQL = exports.oxmysql

local MAX_PLAYLIST_LENGTH = 2048
local MAX_RESPONSE_SIZE = 1048576
local MAX_CHANNELS = 500
local MAX_CHANNEL_NUMBER = 1000
local REQUEST_TIMEOUT = 10000

local function notify(source, message, kind)
    TriggerClientEvent('QBCore:Notify', source, message, kind or 'primary', 5000)
end

local function isValidPlaylistUrl(url)
    if type(url) ~= 'string' or #url == 0 or #url > MAX_PLAYLIST_LENGTH then
        return false
    end

    if not url:match('^https?://') then
        return false
    end

    local host = url:match('^https?://([^/:?#]+)')

    if not host then
        return false
    end

    host = host:lower()

    if host == 'localhost'
        or host:match('^127%.%d+%.%d+%.%d+$')
        or host:match('^10%.%d+%.%d+%.%d+$')
        or host:match('^192%.168%.%d+%.%d+$')
        or host:match('^172%.1[6-9]%.%d+%.%d+$')
        or host:match('^172%.2[0-9]%.%d+%.%d+$')
        or host:match('^172%.3[01]%.%d+%.%d+$') then
        return false
    end

    return true
end

local function isValidChannelUrl(url)
    return isValidPlaylistUrl(url)
end

local function parseM3U(content)
    local channels = {}

    for line in content:gmatch('[^\r\n]+') do
        local name = line:match('#EXTINF:-1[^,]*,(.*)')

        if name and #channels < MAX_CHANNELS then
            channels[#channels + 1] = {
                name = name
            }
        elseif #channels > 0 then
            local url = line:match('^https?://.*')

            if url and isValidChannelUrl(url) then
                channels[#channels].url = url
            end
        end
    end

    local validChannels = {}

    for _, channel in ipairs(channels) do
        if channel.name and channel.url then
            validChannels[#validChannels + 1] = channel
        end
    end

    return validChannels
end

QBCore.Functions.CreateCallback('whellco_iptv:getChannels', function(source, cb, playlistUrl)
    if not isValidPlaylistUrl(playlistUrl) then
        cb({ channels = {} })
        return
    end

    local responded = false

    SetTimeout(REQUEST_TIMEOUT, function()
        if not responded then
            responded = true
            cb({ channels = {} })
        end
    end)

    PerformHttpRequest(playlistUrl, function(status, body)
        if responded then
            return
        end

        responded = true

        if status ~= 200 or type(body) ~= 'string' or #body > MAX_RESPONSE_SIZE then
            cb({ channels = {} })
            return
        end

        cb({ channels = parseM3U(body) })
    end, 'GET', '', {})
end)

local function hasRemote(Player)
    local item = Player.Functions.GetItemByName('tv_remote')

    return item and (item.amount or 0) > 0
end

RegisterNetEvent('whellco_iptv:checkRemote', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    TriggerClientEvent('whellco_iptv:remoteStatus', source, hasRemote(Player))
end)

RegisterNetEvent('whellco_iptv:pickUpRemote', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    if hasRemote(Player) then
        return
    end

    if not Player.Functions.AddItem('tv_remote', 1) then
        notify(source, 'Your inventory is full.', 'error')
        return
    end

    TriggerClientEvent('whellco_iptv:remoteStatus', source, true)
    notify(source, 'You found the TV remote.', 'success')
end)

RegisterNetEvent('whellco_iptv:dropRemote', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    if not hasRemote(Player) then
        return
    end

    if not Player.Functions.RemoveItem('tv_remote', 1) then
        return
    end

    TriggerClientEvent('whellco_iptv:remoteStatus', source, false)
    notify(source, 'You left the house and dropped the TV remote.', 'primary')
end)

QBCore.Functions.CreateCallback('whellco_iptv:getLastChannel', function(source, cb, tvId)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or type(tvId) ~= 'string' or #tvId == 0 then
        cb({ channel = 1 })
        return
    end

    MySQL.query(
        'SELECT channel FROM whellco_iptv_last_channel WHERE citizenid = ? AND tv_id = ?',
        { Player.PlayerData.citizenid, tvId },
        function(result)
            if result and result[1] then
                cb({ channel = result[1].channel })
            else
                cb({ channel = 1 })
            end
        end
    )
end)

RegisterNetEvent('whellco_iptv:saveChannel', function(tvId, channel)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local channelNumber = tonumber(channel)

    if not Player or type(tvId) ~= 'string' or #tvId == 0 or not channelNumber then
        return
    end

    channelNumber = math.floor(channelNumber)

    if channelNumber < 1 or channelNumber > MAX_CHANNEL_NUMBER then
        return
    end

    MySQL.query(
        [[INSERT INTO whellco_iptv_last_channel
            (citizenid, tv_id, channel)
          VALUES (?, ?, ?)
          ON DUPLICATE KEY UPDATE
            channel = VALUES(channel)]],
        {
            Player.PlayerData.citizenid,
            tvId,
            channelNumber
        }
    )
end)