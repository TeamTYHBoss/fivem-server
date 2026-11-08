local QBCore = exports['qb-core']:GetCoreObject()

local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

RegisterNetEvent('whellco_auction_history:openMenu', function()
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    local history = MySQL.query.await(
        [[
            SELECT id, auction_id, action, details, created_at
            FROM whellco_auction_history
            WHERE character_id = ?
            ORDER BY created_at DESC
            LIMIT 25
        ]],
        { Player.PlayerData.citizenid }
    ) or {}

    TriggerClientEvent('whellco_auction_history:openMenu', source, {
        history = history
    })
end)

RegisterNetEvent('whellco_auction_history:closeMenu', function()
    TriggerClientEvent('whellco_auction_history:closeMenu', source)
end)

RegisterNetEvent('whellco_auction_history:recordHistory', function(auctionId, action, details)
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_auction_history
                (character_id, auction_id, action, details)
            VALUES (?, ?, ?, ?)
        ]],
        { Player.PlayerData.citizenid, auctionId, action, details }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Auction history recorded.', 'success')
end)