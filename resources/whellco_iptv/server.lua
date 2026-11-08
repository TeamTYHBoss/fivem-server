local QBCore = exports['qb-core']:GetCoreObject()
local MySQL = exports.oxmysql

local MAX_CHANNELS = 500

local function parseM3U(content)
    local channels = {}

    for line in content:gmatch('[^\r\n]+') do
        local name = line:match('#EXTINF:-1[^,]*,(.*)')

        if name then
            if #channels >= MAX_CHANNELS then
                break
            end

            channels[#channels + 1] = {
                name = name
            }
        else
            local url = line:match('^https?://.*')

            if url and #channels > 0 then
                channels[#channels].url = url
            end
        end
    end

    return channels
end

QBCore.Functions.CreateCallback('whellco_iptv:getChannels', function(source, cb, playlistUrl)
    if type(playlistUrl) ~= 'string' or #playlistUrl == 0 or #playlistUrl > 2048 then
        cb({ channels = {} })
        return
    end

    if not playlistUrl:match('^https?://') then
        cb({ channels = {} })
        return
    end

    PerformHttpRequest(playlistUrl, function(status, body)
        if status ~= 200 or not body then
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
        TriggerClientEvent('QBCore:Notify', source, 'Your inventory is full.', 'error')
        return
    end

    TriggerClientEvent('whellco_iptv:remoteStatus', source, true)
    TriggerClientEvent('QBCore:Notify', source, 'You found the TV remote.', 'success')
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
    TriggerClientEvent('QBCore:Notify', source, 'You left the house and dropped the TV remote.', 'primary')
end)

QBCore.Functions.CreateCallback('whellco_iptv:getLastChannel', function(source, cb, tvId)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not tvId then
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

    if not Player or not tvId or not channelNumber then
        return
    end

    channelNumber = math.floor(channelNumber)

    if channelNumber < 1 or channelNumber > 1000 then
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