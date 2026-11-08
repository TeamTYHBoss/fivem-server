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

    local taxRecords = MySQL.query.await(
        [[
            SELECT id, vehicle_id, owner_id, tax_amount, paid_until, paid_at
            FROM whellco_vehicle_tax_records
            WHERE owner_id = ?
            ORDER BY paid_at DESC
        ]],
        { identifier }
    ) or {}

    local penalties = MySQL.query.await(
        [[
            SELECT id, vehicle_id, owner_id, penalty_amount, reason, created_at
            FROM whellco_vehicle_tax_penalties
            WHERE owner_id = ?
            ORDER BY created_at DESC
            LIMIT 25
        ]],
        { identifier }
    ) or {}

    TriggerClientEvent('whellco_vehicletax:openMenu', source, {
        vehicles = vehicles,
        taxRecords = taxRecords,
        penalties = penalties
    })
end

RegisterNetEvent('whellco_vehicletax:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_vehicletax:closeMenu', function()
    TriggerClientEvent('whellco_vehicletax:closeMenu', source)
end)

RegisterNetEvent('whellco_vehicletax:payTax', function(vehicleId)
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

    MySQL.query.await(
        [[
            INSERT INTO whellco_vehicle_tax_records
                (vehicle_id, owner_id, tax_amount, paid_until)
            VALUES (?, ?, ?, DATE_ADD(NOW(), INTERVAL ? DAY))
            ON DUPLICATE KEY UPDATE tax_amount = VALUES(tax_amount), paid_until = VALUES(paid_until), paid_at = CURRENT_TIMESTAMP
        ]],
        { vehicleId, identifier, Config.TaxAmount, Config.TaxPeriodDays }
    )

    TriggerClientEvent('whellco_vehicletax:notify', source, ('Vehicle tax paid for £%s.'):format(Config.TaxAmount))
    sendMenu(source)
end)

RegisterNetEvent('whellco_vehicletax:payPenalty', function(penaltyId)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    MySQL.query.await(
        [[
            DELETE FROM whellco_vehicle_tax_penalties
            WHERE id = ? AND owner_id = ?
        ]],
        { penaltyId, identifier }
    )

    TriggerClientEvent('whellco_vehicletax:notify', source, 'Penalty paid.')
    sendMenu(source)
end)
