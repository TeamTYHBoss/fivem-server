local QBCore = exports['qb-core']:GetCoreObject()

local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

RegisterNetEvent('whellco_auction_search:search', function(query)
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    query = tostring(query or ''):gsub('^%s+', ''):gsub('%s+$', '')

    if #query == 0 then
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_auction_search
                (character_id, query)
            VALUES (?, ?)
        ]],
        { Player.PlayerData.citizenid, query }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Search saved.', 'success')
end)