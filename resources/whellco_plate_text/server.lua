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

    local plates = MySQL.query.await(
        [[
            SELECT id, vehicle_id, owner_id, plate_text, applied_at
            FROM whellco_vehicle_plate_text
            WHERE owner_id = ?
            ORDER BY applied_at DESC
        ]],
        { identifier }
    ) or {}

    TriggerClientEvent('whellco_plate_text:openMenu', source, {
        vehicles = vehicles,
        plates = plates
    })
end

RegisterNetEvent('whellco_plate_text:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_plate_text:closeMenu', function()
    TriggerClientEvent('whellco_plate_text:closeMenu', source)
end)

RegisterNetEvent('whellco_plate_text:applyPlateText', function(vehicleId, plateText)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    plateText = tostring(plateText or ''):upper():gsub('^%s*(.-)%s*$', '%1')

    if #plateText == 0 or #plateText > Config.MaxPlateLength then
        TriggerClientEvent('whellco_plate_text:notify', source, 'Invalid plate text length.')
        return
    end

    if not plateText:match(Config.AllowedPlatePattern) then
        TriggerClientEvent('whellco_plate_text:notify', source, 'Invalid plate text characters.')
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

    local existing = MySQL.single.await(
        [[
            SELECT id
            FROM whellco_vehicle_plate_text
            WHERE vehicle_id = ?
            LIMIT 1
        ]],
        { vehicleId }
    )

    if existing then
        MySQL.query.await(
            [[
                UPDATE whellco_vehicle_plate_text
                SET plate_text = ?
                WHERE id = ?
            ]],
            { plateText, existing.id }
        )
    else
        MySQL.insert.await(
            [[
                INSERT INTO whellco_vehicle_plate_text
                    (vehicle_id, owner_id, plate_text)
                VALUES (?, ?, ?)
            ]],
            { vehicleId, identifier, plateText }
        )
    end

    TriggerClientEvent('whellco_plate_text:notify', source, ('Custom plate text applied for £%s.'):format(Config.PlateTextPrice))

    sendMenu(source)
end)
