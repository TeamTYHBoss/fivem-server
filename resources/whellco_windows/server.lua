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

    local windows = MySQL.query.await(
        [[
            SELECT id, vehicle_id, owner_id, window_tint, window_color, applied_at
            FROM whellco_vehicle_windows
            WHERE owner_id = ?
            ORDER BY applied_at DESC
        ]],
        { identifier }
    ) or {}

    TriggerClientEvent('whellco_windows:openMenu', source, {
        vehicles = vehicles,
        windows = windows,
        tints = Config.WindowTints,
        colors = Config.WindowColors
    })
end

RegisterNetEvent('whellco_windows:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_windows:closeMenu', function()
    TriggerClientEvent('whellco_windows:closeMenu', source)
end)

RegisterNetEvent('whellco_windows:applyWindows', function(vehicleId, tintId, colorId)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    tintId = tonumber(tintId) or 0
    colorId = tonumber(colorId) or 0

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
            FROM whellco_vehicle_windows
            WHERE vehicle_id = ?
            LIMIT 1
        ]],
        { vehicleId }
    )

    if existing then
        MySQL.query.await(
            [[
                UPDATE whellco_vehicle_windows
                SET window_tint = ?, window_color = ?
                WHERE id = ?
            ]],
            { tintId, colorId, existing.id }
        )
    else
        MySQL.insert.await(
            [[
                INSERT INTO whellco_vehicle_windows
                    (vehicle_id, owner_id, window_tint, window_color)
                VALUES (?, ?, ?, ?)
            ]],
            { vehicleId, identifier, tintId, colorId }
        )
    end

    TriggerClientEvent('whellco_windows:notify', source, ('Windows applied for £%s.'):format(Config.WindowPrice))

    sendMenu(source)
end)
