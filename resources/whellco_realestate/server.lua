local function getIdentifier(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')

    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'steam')
    end

    return identifier
end

local function sendMenu(source)
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local properties = MySQL.query.await(
        [[
            SELECT property_id, label, price, rent, owner_id, is_rented
            FROM whellco_properties
            ORDER BY price ASC
        ]]
    ) or {}

    local purchases = MySQL.query.await(
        [[
            SELECT id, property_id, buyer_id, price, purchased_at
            FROM whellco_property_purchases
            WHERE buyer_id = ?
            ORDER BY purchased_at DESC
            LIMIT 25
        ]],
        { identifier }
    ) or {}

    local rentals = MySQL.query.await(
        [[
            SELECT id, property_id, tenant_id, rent, started_at, ended_at
            FROM whellco_property_rentals
            WHERE tenant_id = ?
            ORDER BY started_at DESC
            LIMIT 25
        ]],
        { identifier }
    ) or {}

    TriggerClientEvent('whellco_realestate:openMenu', source, {
        properties = properties,
        purchases = purchases,
        rentals = rentals
    })
end

RegisterNetEvent('whellco_realestate:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_realestate:closeMenu', function()
    TriggerClientEvent('whellco_realestate:closeMenu', source)
end)

RegisterNetEvent('whellco_realestate:buyProperty', function(propertyId)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local property = MySQL.single.await(
        [[
            SELECT property_id, label, price, owner_id
            FROM whellco_properties
            WHERE property_id = ?
            LIMIT 1
        ]],
        { propertyId }
    )

    if not property then
        return
    end

    if property.owner_id then
        TriggerClientEvent('whellco_realestate:notify', source, 'That property is already owned.')
        return
    end

    MySQL.transaction.await({
        {
            query = [[
                UPDATE whellco_properties
                SET owner_id = ?, is_rented = 0
                WHERE property_id = ? AND owner_id IS NULL
            ]],
            values = { identifier, propertyId }
        },
        {
            query = [[
                INSERT INTO whellco_property_purchases
                    (property_id, buyer_id, price)
                VALUES (?, ?, ?)
            ]],
            values = { propertyId, identifier, property.price }
        }
    })

    TriggerClientEvent('whellco_realestate:notify', source, ('You bought %s for £%s.'):format(property.label, property.price))
    sendMenu(source)
end)

RegisterNetEvent('whellco_realestate:rentProperty', function(propertyId)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local property = MySQL.single.await(
        [[
            SELECT property_id, label, rent, is_rented
            FROM whellco_properties
            WHERE property_id = ?
            LIMIT 1
        ]],
        { propertyId }
    )

    if not property then
        return
    end

    if property.is_rented == 1 then
        TriggerClientEvent('whellco_realestate:notify', source, 'That property is already rented.')
        return
    end

    MySQL.transaction.await({
        {
            query = [[
                UPDATE whellco_properties
                SET is_rented = 1
                WHERE property_id = ? AND is_rented = 0
            ]],
            values = { propertyId }
        },
        {
            query = [[
                INSERT INTO whellco_property_rentals
                    (property_id, tenant_id, rent)
                VALUES (?, ?, ?)
            ]],
            values = { propertyId, identifier, property.rent }
        }
    })

    TriggerClientEvent('whellco_realestate:notify', source, ('You rented %s for £%s.'):format(property.label, property.rent))
    sendMenu(source)
end)

RegisterNetEvent('whellco_realestate:sellProperty', function(propertyId)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local property = MySQL.single.await(
        [[
            SELECT property_id, label, owner_id
            FROM whellco_properties
            WHERE property_id = ?
            LIMIT 1
        ]],
        { propertyId }
    )

    if not property or property.owner_id ~= identifier then
        return
    end

    MySQL.transaction.await({
        {
            query = [[
                UPDATE whellco_properties
                SET owner_id = NULL, is_rented = 0
                WHERE property_id = ?
            ]],
            values = { propertyId }
        },
        {
            query = [[
                UPDATE whellco_property_rentals
                SET ended_at = CURRENT_TIMESTAMP
                WHERE property_id = ? AND ended_at IS NULL
            ]],
            values = { propertyId }
        }
    })

    TriggerClientEvent('whellco_realestate:notify', source, ('You sold %s.'):format(property.label))
    sendMenu(source)
end)
