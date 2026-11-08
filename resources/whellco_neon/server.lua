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

    local neons = MySQL.query.await(
        [[
            SELECT id, vehicle_id, owner_id, color_id, style_id, applied_at
            FROM whellco_vehicle_neons
            WHERE owner_id = ?
            ORDER BY applied_at DESC
        ]],
        { identifier }
    ) or {}

    TriggerClientEvent('whellco_neon:openMenu', source, {
        vehicles = vehicles,
        neons = neons,
        colors = Config.NeonColors,
        styles = Config.NeonStyles
    })
end

RegisterNetEvent('whellco_neon:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_neon:closeMenu', function()
    TriggerClientEvent('whellco_neon:closeMenu', source)
end)

RegisterNetEvent('whellco_neon:applyNeon', function(vehicleId, colorId, styleId)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    colorId = tonumber(colorId) or 0
    styleId = tonumber(styleId) or 0

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

    local existing = MySQL.single.await(
        [[
            SELECT id
            FROM whellco_vehicle_neons
            WHERE vehicle_id = ?
            LIMIT 1
        ]],
        { vehicleId }
    )

    if existing then
        MySQL.query.await(
            [[
                UPDATE whellco_vehicle_neons
                SET color_id = ?, style_id = ?
                WHERE id = ?
            ]],
            { colorId, styleId, existing.id }
        )
    else
        MySQL.insert.await(
            [[
                INSERT INTO whellco_vehicle_neons
                    (vehicle_id, owner_id, color_id, style_id)
                VALUES (?, ?, ?, ?)
            ]],
            { vehicleId, identifier, colorId, styleId }
        )
    end

    TriggerClientEvent('whellco_neon:notify', source, ('Neon applied for £%s.'):format(Config.NeonPrice))

    sendMenu(source)
end)
