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
            SELECT id, vehicle_id, owner_id, plate_type, plate_color, applied_at
            FROM whellco_vehicle_plates
            WHERE owner_id = ?
            ORDER BY applied_at DESC
        ]],
        { identifier }
    ) or {}

    TriggerClientEvent('whellco_plates:openMenu', source, {
        vehicles = vehicles,
        plates = plates,
        types = Config.PlateTypes,
        colors = Config.PlateColors
    })
end

RegisterNetEvent('whellco_plates:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_plates:closeMenu', function()
    TriggerClientEvent('whellco_plates:closeMenu', source)
end)

RegisterNetEvent('whellco_plates:applyPlate', function(vehicleId, typeId, colorId)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    typeId = tonumber(typeId) or 0
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
            FROM whellco_vehicle_plates
            WHERE vehicle_id = ?
            LIMIT 1
        ]],
        { vehicleId }
    )

    if existing then
        MySQL.query.await(
            [[
                UPDATE whellco_vehicle_plates
                SET plate_type = ?, plate_color = ?
                WHERE id = ?
            ]],
            { typeId, colorId, existing.id }
        )
    else
        MySQL.insert.await(
            [[
                INSERT INTO whellco_vehicle_plates
                    (vehicle_id, owner_id, plate_type, plate_color)
                VALUES (?, ?, ?, ?)
            ]],
            { vehicleId, identifier, typeId, colorId }
        )
    end

    TriggerClientEvent('whellco_plates:notify', source, ('Plate applied for £%s.'):format(Config.PlatePrice))

    sendMenu(source)
end)
