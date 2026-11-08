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

    local certificates = MySQL.query.await(
        [[
            SELECT id, vehicle_id, owner_id, passed, expiry_date, issued_at
            FROM whellco_mot_certificates
            WHERE owner_id = ?
            ORDER BY issued_at DESC
        ]],
        { identifier }
    ) or {}

    local failures = MySQL.query.await(
        [[
            SELECT id, vehicle_id, owner_id, failure_reason, failed_at
            FROM whellco_mot_failures
            WHERE owner_id = ?
            ORDER BY failed_at DESC
            LIMIT 25
        ]],
        { identifier }
    ) or {}

    TriggerClientEvent('whellco_mot:openMenu', source, {
        vehicles = vehicles,
        certificates = certificates,
        failures = failures
    })
end

RegisterNetEvent('whellco_mot:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_mot:closeMenu', function()
    TriggerClientEvent('whellco_mot:closeMenu', source)
end)

RegisterNetEvent('whellco_mot:bookMot', function(vehicleId)
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

    local passed = math.random(1, 10) > 2

    if passed then
        MySQL.query.await(
            [[
                INSERT INTO whellco_mot_certificates
                    (vehicle_id, owner_id, passed, expiry_date)
                VALUES (?, ?, 1, DATE_ADD(NOW(), INTERVAL ? DAY))
            ]],
            { vehicleId, identifier, Config.MOTPeriodDays }
        )

        TriggerClientEvent('whellco_mot:notify', source, ('MOT passed for £%s. Valid for %s days.'):format(Config.MOTPrice, Config.MOTPeriodDays))
    else
        local reasons = {
            'Brake condition failed.',
            'Tyre condition failed.',
            'Lights and indicators failed.',
            'Emissions failed.'
        }

        local reason = reasons[math.random(1, #reasons)]

        MySQL.insert.await(
            [[
                INSERT INTO whellco_mot_failures
                    (vehicle_id, owner_id, failure_reason)
                VALUES (?, ?, ?)
            ]],
            { vehicleId, identifier, reason }
        )

        TriggerClientEvent('whellco_mot:notify', source, ('MOT failed: %s'):format(reason))
    end

    sendMenu(source)
end)
