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

    local previews = MySQL.query.await(
        [[
            SELECT id, vehicle_id, owner_id, plate_type, plate_color, plate_text, created_at
            FROM whellco_plate_previews
            WHERE owner_id = ?
            ORDER BY created_at DESC
        ]],
        { identifier }
    ) or {}

    TriggerClientEvent('whellco_plate_preview:openMenu', source, {
        vehicles = vehicles,
        previews = previews,
        types = Config.PlateTypes,
        colors = Config.PlateColors
    })
end

RegisterNetEvent('whellco_plate_preview:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_plate_preview:closeMenu', function()
    TriggerClientEvent('whellco_plate_preview:closeMenu', source)
end)

RegisterNetEvent('whellco_plate_preview:previewPlate', function(vehicleId, typeId, colorId, plateText)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    typeId = tonumber(typeId) or 0
    colorId = tonumber(colorId) or 0
    plateText = tostring(plateText or ''):upper():gsub('^%s*(.-)%s*$', '%1')

    if #plateText > 8 then
        plateText = plateText:sub(1, 8)
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

    local existing = MySQL.single.await(
        [[
            SELECT id
            FROM whellco_plate_previews
            WHERE vehicle_id = ?
            LIMIT 1
        ]],
        { vehicleId }
    )

    if existing then
        MySQL.query.await(
            [[
                UPDATE whellco_plate_previews
                SET plate_type = ?, plate_color = ?, plate_text = ?
                WHERE id = ?
            ]],
            { typeId, colorId, plateText, existing.id }
        )
    else
        MySQL.insert.await(
            [[
                INSERT INTO whellco_plate_previews
                    (vehicle_id, owner_id, plate_type, plate_color, plate_text)
                VALUES (?, ?, ?, ?, ?)
            ]],
            { vehicleId, identifier, typeId, colorId, plateText }
        )
    end

    TriggerClientEvent('whellco_plate_preview:notify', source, ('Plate preview saved for £%s.'):format(Config.PreviewPrice))

    sendMenu(source)
end)
