local QBCore = exports['qb-core']:GetCoreObject()
local MySQL = exports.oxmysql

local MAX_PLAYLIST_LENGTH = 2048
local MAX_RESPONSE_SIZE = 1048576
local MAX_CHANNELS = 500
local MAX_CHANNEL_NUMBER = 1000
local REQUEST_TIMEOUT = 10000

local TRUSTED_PLAYLIST_DOMAINS = Config.TrustedPlaylistDomains or {
    'raw.githubusercontent.com',
    'gist.githubusercontent.com'
}

local PLAYLIST_CACHE_SECONDS = Config.PlaylistCacheSeconds or 300
local playlistCache = {}

local function notify(source, message, kind)
    TriggerClientEvent('QBCore:Notify', source, message, kind or 'primary', 5000)
end

local function isPrivateHost(host)
    if host == 'localhost' then
        return true
    end

    if host:match('^127%.%d+%.%d+%.%d+$')
        or host:match('^10%.%d+%.%d+%.%d+$')
        or host:match('^192%.168%.%d+%.%d+$')
        or host:match('^172%.1[6-9]%.%d+%.%d+$')
        or host:match('^172%.2[0-9]%.%d+%.%d+$')
        or host:match('^172%.3[01]%.%d+%.%d+$') then
        return true
    end

    local lowerHost = host:lower()

    if lowerHost == '::1'
        or lowerHost == 'fe80::'
        or lowerHost:match('^fc[0-9a-f][0-9a-f]:')
        or lowerHost:match('^fd[0-9a-f][0-9a-f]:') then
        return true
    end

    local mappedIpv4 = lowerHost:match('^::ffff:(%d+%.%d+%.%d+%.%d+)$')

    if mappedIpv4 then
        return isPrivateHost(mappedIpv4)
    end

    return false
end

local function isTrustedHost(host)
    for _, domain in ipairs(TRUSTED_PLAYLIST_DOMAINS) do
        if host == domain then
            return true
        end

        local suffix = ('.%s'):format(domain)

        if host:sub(-#suffix) == suffix then
            return true
        end
    end

    return false
end

local function isValidUrl(url, requireTrusted)
    if type(url) ~= 'string' or #url == 0 or #url > MAX_PLAYLIST_LENGTH then
        return false
    end

    if not url:match('^https?://') then
        return false
    end

    local host = url:match('^https?://([^/:?#]+)')

    if not host or host == '' then
        return false
    end

    if host:find('%[') then
        local ipv6 = host:match('^%[(.+)%]$')

        if not ipv6 or isPrivateHost(ipv6) then
            return false
        end
    else
        if isPrivateHost(host) then
            return false
        end
    end

    if requireTrusted and not isTrustedHost(host:lower()) then
        return false
    end

    return true
end

local function isValidPlaylistUrl(url)
    return isValidUrl(url, true)
end

local function isValidChannelUrl(url)
    return isValidUrl(url, true)
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

local function getCachedPlaylist(url)
    local cached = playlistCache[url]

    if not cached then
        return nil
    end

    if GetGameTimer() - cached.time > PLAYLIST_CACHE_SECONDS * 1000 then
        playlistCache[url] = nil
        return nil
    end

    return cached.channels
end

local function cachePlaylist(url, channels)
    playlistCache[url] = {
        time = GetGameTimer(),
        channels = channels
    }
end

QBCore.Functions.CreateCallback('whellco_iptv:getChannels', function(source, cb, playlistUrl)
    if not isValidPlaylistUrl(playlistUrl) then
        cb({ channels = {} })
        return
    end

    local cached = getCachedPlaylist(playlistUrl)

    if cached then
        cb({ channels = cached })
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

        local channels = parseM3U(body)

        cachePlaylist(playlistUrl, channels)
        cb({ channels = channels })
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
