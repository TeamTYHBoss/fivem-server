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

    local wheels = MySQL.query.await(
        [[
            SELECT id, vehicle_id, owner_id, wheel_type, wheel_color, applied_at
            FROM whellco_vehicle_wheels
            WHERE owner_id = ?
            ORDER BY applied_at DESC
        ]],
        { identifier }
    ) or {}

    TriggerClientEvent('whellco_wheels:openMenu', source, {
        vehicles = vehicles,
        wheels = wheels,
        wheelTypes = Config.WheelTypes,
        wheelColors = Config.WheelColors
    })
end

RegisterNetEvent('whellco_wheels:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_wheels:closeMenu', function()
    TriggerClientEvent('whellco_wheels:closeMenu', source)
end)

RegisterNetEvent('whellco_wheels:applyWheels', function(vehicleId, wheelType, wheelColor)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    wheelType = tonumber(wheelType) or 0
    wheelColor = tonumber(wheelColor) or 0

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
            FROM whellco_vehicle_wheels
            WHERE vehicle_id = ?
            LIMIT 1
        ]],
        { vehicleId }
    )

    if existing then
        MySQL.query.await(
            [[
                UPDATE whellco_vehicle_wheels
                SET wheel_type = ?, wheel_color = ?
                WHERE id = ?
            ]],
            { wheelType, wheelColor, existing.id }
        )
    else
        MySQL.insert.await(
            [[
                INSERT INTO whellco_vehicle_wheels
                    (vehicle_id, owner_id, wheel_type, wheel_color)
                VALUES (?, ?, ?, ?)
            ]],
            { vehicleId, identifier, wheelType, wheelColor }
        )
    end

    TriggerClientEvent('whellco_wheels:notify', source, ('Wheels applied for £%s.'):format(Config.WheelPrice))

    sendMenu(source)
end)
