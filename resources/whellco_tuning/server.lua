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

    local vehicles = MySQL.query.await(
        [[
            SELECT id, model, plate
            FROM whellco_vehicles
            WHERE owner_id = ?
            ORDER BY created_at DESC
        ]],
        { identifier }
    ) or {}

    local upgrades = MySQL.query.await(
        [[
            SELECT id, vehicle_id, owner_id, part, level, installed_at
            FROM whellco_tuning_upgrades
            WHERE owner_id = ?
            ORDER BY installed_at DESC
        ]],
        { identifier }
    ) or {}

    TriggerClientEvent('whellco_tuning:openMenu', source, {
        vehicles = vehicles,
        upgrades = upgrades
    })
end

RegisterNetEvent('whellco_tuning:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_tuning:closeMenu', function()
    TriggerClientEvent('whellco_tuning:closeMenu', source)
end)

RegisterNetEvent('whellco_tuning:installUpgrade', function(vehicleId, part)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local vehicle = MySQL.single.await(
        [[
            SELECT id
            FROM whellco_vehicles
            WHERE id = ? AND owner_id = ?
            LIMIT 1
        ]],
        { vehicleId, identifier }
    )

    if not vehicle then
        return
    end

    local price = Config.TuningPrices[part]

    if not price then
        return
    end

    local existing = MySQL.single.await(
        [[
            SELECT id, level
            FROM whellco_tuning_upgrades
            WHERE vehicle_id = ? AND part = ?
            LIMIT 1
        ]],
        { vehicleId, part }
    )

    if existing then
        MySQL.query.await(
            [[
                UPDATE whellco_tuning_upgrades
                SET level = level + 1
                WHERE id = ?
            ]],
            { existing.id }
        )
    else
        MySQL.insert.await(
            [[
                INSERT INTO whellco_tuning_upgrades
                    (vehicle_id, owner_id, part, level)
                VALUES (?, ?, ?, 1)
            ]],
            { vehicleId, identifier, part }
        )
    end

    TriggerClientEvent('whellco_tuning:notify', source, ('Installed %s for £%s.'):format(Config.TuningParts[part], price))

    sendMenu(source)
end)
