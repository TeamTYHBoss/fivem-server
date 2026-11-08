local QBCore = exports['qb-core']:GetCoreObject()

local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

RegisterNetEvent('whellco_auction_categories:openMenu', function()
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    local categories = MySQL.query.await(
        [[
            SELECT id, auction_id, category, created_at
            FROM whellco_auction_categories
            WHERE character_id = ?
            ORDER BY created_at DESC
            LIMIT 25
        ]],
        { Player.PlayerData.citizenid }
    ) or {}

    TriggerClientEvent('whellco_auction_categories:openMenu', source, {
        categories = categories
    })
end)

RegisterNetEvent('whellco_auction_categories:closeMenu', function()
    TriggerClientEvent('whellco_auction_categories:closeMenu', source)
end)

RegisterNetEvent('whellco_auction_categories:addCategory', function(auctionId, category)
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_auction_categories
                (character_id, auction_id, category)
            VALUES (?, ?, ?)
        ]],
        { Player.PlayerData.citizenid, auctionId, category }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Category added.', 'success')
end)