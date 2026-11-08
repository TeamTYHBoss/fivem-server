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

    local wanted = MySQL.query.await(
        [[
            SELECT id, vehicle_id, owner_id, wanted_level, reason, updated_at
            FROM whellco_wanted_levels
            WHERE owner_id = ? AND wanted_level > 0
            ORDER BY wanted_level DESC
        ]],
        { identifier }
    ) or {}

    TriggerClientEvent('whellco_wanted:openMenu', source, {
        wanted = wanted
    })
end

RegisterNetEvent('whellco_wanted:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_wanted:closeMenu', function()
    TriggerClientEvent('whellco_wanted:closeMenu', source)
end)

RegisterNetEvent('whellco_wanted:setWanted', function(vehicleId, level, reason)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    level = tonumber(level) or 0

    if level < 0 then
        level = 0
    end

    if level > Config.MaxWantedLevel then
        level = Config.MaxWantedLevel
    end

    local existing = MySQL.single.await(
        [[
            SELECT id
            FROM whellco_wanted_levels
            WHERE vehicle_id = ? AND owner_id = ?
            LIMIT 1
        ]],
        { vehicleId, identifier }
    )

    if existing then
        MySQL.query.await(
            [[
                UPDATE whellco_wanted_levels
                SET wanted_level = ?, reason = ?
                WHERE id = ?
            ]],
            { level, reason or 'Unknown', existing.id }
        )
    else
        MySQL.insert.await(
            [[
                INSERT INTO whellco_wanted_levels
                    (vehicle_id, owner_id, wanted_level, reason)
                VALUES (?, ?, ?, ?)
            ]],
            { vehicleId, identifier, level, reason or 'Unknown' }
        )
    end

    if level > 0 then
        TriggerClientEvent('whellco_wanted:notify', source, ('Vehicle wanted level set to %s.'):format(level))
        TriggerClientEvent('whellco_police:alert', -1, ('Vehicle wanted level %s: %s'):format(level, reason or 'Unknown'))
    end

    sendMenu(source)
end)
