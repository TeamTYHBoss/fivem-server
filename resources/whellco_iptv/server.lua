local QBCore = exports['qb-core']:GetCoreObject()

local function parseM3U(content)
    local channels = {}

    for line in content:gmatch('[^\r\n]+') do
        local name = line:match('#EXTINF:-1[^,]*,(.*)')

        if name then
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
    if not playlistUrl then
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