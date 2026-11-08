local function getIdentifier(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')

    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'steam')
    end

    return identifier
end

local function sendMenu(source, results)
    TriggerClientEvent('whellco_auction_search:openMenu', source, {
        results = results or {},
        filters = Config.SearchFilters
    })
end

RegisterNetEvent('whellco_auction_search:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_auction_search:closeMenu', function()
    TriggerClientEvent('whellco_auction_search:closeMenu', source)
end)

RegisterNetEvent('whellco_auction_search:searchAuctions', function(searchQuery, searchFilter)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    searchQuery = tostring(searchQuery or ''):upper():gsub('^%s*(.-)%s*$', '%1')
    searchFilter = tostring(searchFilter or 'plate')

    if searchQuery == '' then
        return
    end

    local results = {}

    if searchFilter == 'plate' then
        results = MySQL.query.await(
            [[
                SELECT id, plate, seller_id, starting_bid, current_bid, ends_at, status
                FROM whellco_plate_auctions
                WHERE plate LIKE ? AND status = 'active'
                ORDER BY ends_at ASC
                LIMIT ?
            ]],
            { '%' .. searchQuery .. '%', Config.MaxSearchResults }
        ) or {}
    elseif searchFilter == 'seller' then
        results = MySQL.query.await(
            [[
                SELECT id, plate, seller_id, starting_bid, current_bid, ends_at, status
                FROM whellco_plate_auctions
                WHERE seller_id LIKE ? AND status = 'active'
                ORDER BY ends_at ASC
                LIMIT ?
            ]],
            { '%' .. searchQuery .. '%', Config.MaxSearchResults }
        ) or {}
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_auction_searches
                (player_id, search_query, search_filter)
            VALUES (?, ?, ?)
        ]],
        { identifier, searchQuery, searchFilter }
    )

    TriggerClientEvent('whellco_auction_search:notify', source, ('Found %s auction results.'):format(#results))

    sendMenu(source, results)
end)
