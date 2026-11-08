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

    local paints = MySQL.query.await(
        [[
            SELECT id, vehicle_id, owner_id, color_id, finish_id, applied_at
            FROM whellco_vehicle_paints
            WHERE owner_id = ?
            ORDER BY applied_at DESC
        ]],
        { identifier }
    ) or {}

    TriggerClientEvent('whellco_paint:openMenu', source, {
        vehicles = vehicles,
        paints = paints,
        colors = Config.PaintColors,
        finishes = Config.PaintFinishes
    })
end

RegisterNetEvent('whellco_paint:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_paint:closeMenu', function()
    TriggerClientEvent('whellco_paint:closeMenu', source)
end)

RegisterNetEvent('whellco_paint:applyPaint', function(vehicleId, colorId, finishId)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    colorId = tonumber(colorId) or 0
    finishId = tonumber(finishId) or 0

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
            FROM whellco_vehicle_paints
            WHERE vehicle_id = ?
            LIMIT 1
        ]],
        { vehicleId }
    )

    if existing then
        MySQL.query.await(
            [[
                UPDATE whellco_vehicle_paints
                SET color_id = ?, finish_id = ?
                WHERE id = ?
            ]],
            { colorId, finishId, existing.id }
        )
    else
        MySQL.insert.await(
            [[
                INSERT INTO whellco_vehicle_paints
                    (vehicle_id, owner_id, color_id, finish_id)
                VALUES (?, ?, ?, ?)
            ]],
            { vehicleId, identifier, colorId, finishId }
        )
    end

    TriggerClientEvent('whellco_paint:notify', source, ('Paint applied for £%s.'):format(Config.PaintPrice))

    sendMenu(source)
end)
