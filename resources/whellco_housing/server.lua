local QBCore = exports['qb-core']:GetCoreObject()

local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

local function getProperties()
    local rows = MySQL.query.await('SELECT property_id, owner_character_id, price FROM whellco_properties') or {}
    local properties = {}

    for _, row in ipairs(rows) do
        properties[row.property_id] = row
    end

    return properties
end

local function sendMenu(source)
    local properties = getProperties()
    local list = {}

    for id, property in pairs(properties) do
        list[#list + 1] = {
            id = id,
            label = Config.Properties[id].label,
            price = property.price,
            owner = property.owner_character_id
        }
    end

    TriggerClientEvent('whellco_housing:openMenu', source, {
        properties = list,
        furniture = Config.Furniture
    })
end

RegisterNetEvent('whellco_housing:openMenu', function()
    local source = source

    sendMenu(source)
end)

RegisterNetEvent('whellco_housing:closeMenu', function()
    local source = source

    TriggerClientEvent('whellco_housing:closeMenu', source)
end)

RegisterNetEvent('whellco_housing:buyProperty', function(propertyId)
    local source = source
    local Player = getQbPlayer(source)
    local property = Config.Properties[propertyId]

    if not Player or not property then
        return
    end

    local citizenId = Player.PlayerData.citizenid

    local existing = MySQL.single.await(
        'SELECT owner_character_id FROM whellco_properties WHERE property_id = ? LIMIT 1',
        { propertyId }
    )

    if existing and existing.owner_character_id then
        TriggerClientEvent('QBCore:Notify', source, 'That property is already owned.', 'error')
        return
    end

    if Player.Functions.GetMoney('cash') < property.price then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have enough cash.', 'error')
        return
    end

    if not Player.Functions.RemoveMoney('cash', property.price, ('Purchased %s'):format(property.label)) then
        TriggerClientEvent('QBCore:Notify', source, 'Purchase failed.', 'error')
        return
    end

    MySQL.query.await(
        [[
            INSERT INTO whellco_properties (property_id, owner_character_id, price)
            VALUES (?, ?, ?)
            ON DUPLICATE KEY UPDATE owner_character_id = VALUES(owner_character_id), price = VALUES(price)
        ]],
        { propertyId, citizenId, property.price }
    )

    MySQL.query.await(
        [[
            INSERT INTO whellco_property_keys (property_id, character_id)
            VALUES (?, ?)
            ON DUPLICATE KEY UPDATE character_id = VALUES(character_id)
        ]],
        { propertyId, citizenId }
    )

    TriggerClientEvent('QBCore:Notify', source, ('Purchased %s for %s%d.'):format(property.label, Config.Currency, property.price), 'success')
end)

RegisterNetEvent('whellco_housing:enterProperty', function(propertyId)
    local source = source
    local Player = getQbPlayer(source)
    local property = Config.Properties[propertyId]

    if not Player or not property then
        return
    end

    local citizenId = Player.PlayerData.citizenid

    local key = MySQL.single.await(
        'SELECT id FROM whellco_property_keys WHERE property_id = ? AND character_id = ? LIMIT 1',
        { propertyId, citizenId }
    )

    if not key then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have a key for this property.', 'error')
        return
    end

    TriggerClientEvent('whellco_housing:enterProperty', source, {
        coords = property.interior
    })
end)

RegisterNetEvent('whellco_housing:exitProperty', function(propertyId)
    local source = source
    local property = Config.Properties[propertyId]

    if not property then
        return
    end

    TriggerClientEvent('whellco_housing:exitProperty', source, {
        coords = property.entrance
    })
end)

RegisterNetEvent('whellco_housing:placeFurniture', function(data)
    local source = source
    local Player = getQbPlayer(source)
    local property = Config.Properties[data.propertyId]
    local item = Config.Furniture[data.itemId]

    if not Player or not property or not item then
        return
    end

    local citizenId = Player.PlayerData.citizenid

    local key = MySQL.single.await(
        'SELECT id FROM whellco_property_keys WHERE property_id = ? AND character_id = ? LIMIT 1',
        { data.propertyId, citizenId }
    )

    if not key then
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_property_furniture
                (property_id, item, x, y, z, heading)
            VALUES (?, ?, ?, ?, ?, ?)
        ]],
        { data.propertyId, data.itemId, data.x, data.y, data.z, data.heading or 0.0 }
    )

    TriggerClientEvent('QBCore:Notify', source, ('Placed %s.'):format(item.label), 'success')
end)