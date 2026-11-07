local function getIdentifier(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')

    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'steam')
    end

    return identifier
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
    local property = Config.Properties[propertyId]

    if not property then
        return
    end

    local characterId = GetPlayerIdentifierByType(source, 'license')

    if not characterId then
        return
    end

    local existing = MySQL.single.await(
        'SELECT owner_character_id FROM whellco_properties WHERE property_id = ? LIMIT 1',
        { propertyId }
    )

    if existing and existing.owner_character_id then
        TriggerClientEvent('whellco_housing:notify', source, 'That property is already owned.')
        return
    end

    local account = MySQL.single.await(
        'SELECT cash FROM whellco_players WHERE character_id = ? LIMIT 1',
        { characterId }
    )

    if not account or (account.cash or 0) < property.price then
        TriggerClientEvent('whellco_housing:notify', source, 'You do not have enough cash.')
        return
    end

    MySQL.transaction.await({
        {
            query = 'UPDATE whellco_players SET cash = cash - ? WHERE character_id = ? AND cash >= ?',
            values = { property.price, characterId, property.price }
        },
        {
            query = [[
                INSERT INTO whellco_properties (property_id, owner_character_id, price)
                VALUES (?, ?, ?)
                ON DUPLICATE KEY UPDATE owner_character_id = VALUES(owner_character_id), price = VALUES(price)
            ]],
            values = { propertyId, characterId, property.price }
        },
        {
            query = [[
                INSERT INTO whellco_property_keys (property_id, character_id)
                VALUES (?, ?)
                ON DUPLICATE KEY UPDATE character_id = VALUES(character_id)
            ]],
            values = { propertyId, characterId }
        }
    })

    TriggerClientEvent('whellco_housing:notify', source, ('Purchased %s for %s%d.'):format(property.label, Config.Currency, property.price))
end)

RegisterNetEvent('whellco_housing:enterProperty', function(propertyId)
    local source = source
    local property = Config.Properties[propertyId]

    if not property then
        return
    end

    local characterId = GetPlayerIdentifierByType(source, 'license')

    if not characterId then
        return
    end

    local key = MySQL.single.await(
        'SELECT id FROM whellco_property_keys WHERE property_id = ? AND character_id = ? LIMIT 1',
        { propertyId, characterId }
    )

    if not key then
        TriggerClientEvent('whellco_housing:notify', source, 'You do not have a key for this property.')
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
    local propertyId = tostring(data.propertyId or '')
    local itemId = tostring(data.itemId or '')
    local item = Config.Furniture[itemId]

    if not property or not item then
        return
    end

    local characterId = GetPlayerIdentifierByType(source, 'license')

    if not characterId then
        return
    end

    local key = MySQL.single.await(
        'SELECT id FROM whellco_property_keys WHERE property_id = ? AND character_id = ? LIMIT 1',
        { propertyId, characterId }
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
        { propertyId, itemId, data.x, data.y, data.z, data.heading or 0.0 }
    )

    TriggerClientEvent('whellco_housing:notify', source, ('Placed %s.'):format(item.label))
end)
