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

    local listings = MySQL.query.await(
        [[
            SELECT id, plate, seller_id, price, status, listed_at
            FROM whellco_plate_listings
            WHERE status = 'active'
            ORDER BY listed_at DESC
        ]]
    ) or {}

    TriggerClientEvent('whellco_plate_market:openMenu', source, {
        listings = listings
    })
end

RegisterNetEvent('whellco_plate_market:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_plate_market:closeMenu', function()
    TriggerClientEvent('whellco_plate_market:closeMenu', source)
end)

RegisterNetEvent('whellco_plate_market:buyPlate', function(listingId)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local listing = MySQL.single.await(
        [[
            SELECT id, plate, seller_id, price, status
            FROM whellco_plate_listings
            WHERE id = ? AND status = 'active'
            LIMIT 1
        ]],
        { listingId }
    )

    if not listing then
        return
    end

    if listing.seller_id == identifier then
        return
    end

    MySQL.query.await(
        [[
            UPDATE whellco_plate_listings
            SET status = 'sold', buyer_id = ?, sold_at = NOW()
            WHERE id = ? AND status = 'active'
        ]],
        { identifier, listing.id }
    )

    TriggerClientEvent('whellco_plate_market:notify', source, ('Purchased plate %s for £%s.'):format(listing.plate, listing.price))

    sendMenu(source)
end)
