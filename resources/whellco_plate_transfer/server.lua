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

    local transfers = MySQL.query.await(
        [[
            SELECT id, vehicle_id, from_owner_id, to_owner_id, plate, transfer_fee, transferred_at
            FROM whellco_plate_transfers
            WHERE from_owner_id = ? OR to_owner_id = ?
            ORDER BY transferred_at DESC
            LIMIT 25
        ]],
        { identifier, identifier }
    ) or {}

    TriggerClientEvent('whellco_plate_transfer:openMenu', source, {
        vehicles = vehicles,
        transfers = transfers
    })
end

RegisterNetEvent('whellco_plate_transfer:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_plate_transfer:closeMenu', function()
    TriggerClientEvent('whellco_plate_transfer:closeMenu', source)
end)

RegisterNetEvent('whellco_plate_transfer:transferPlate', function(vehicleId, targetId, plate)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    plate = tostring(plate or ''):upper():gsub('^%s*(.-)%s*$', '%1')

    if #plate == 0 or #plate > Config.MaxPlateLength then
        TriggerClientEvent('whellco_plate_transfer:notify', source, 'Invalid plate length.')
        return
    end

    if not plate:match(Config.AllowedPlatePattern) then
        TriggerClientEvent('whellco_plate_transfer:notify', source, 'Invalid plate characters.')
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

    MySQL.insert.await(
        [[
            INSERT INTO whellco_plate_transfers
                (vehicle_id, from_owner_id, to_owner_id, plate, transfer_fee)
            VALUES (?, ?, ?, ?, ?)
        ]],
        { vehicleId, identifier, targetId, plate, Config.TransferFee }
    )

    TriggerClientEvent('whellco_plate_transfer:notify', source, ('Plate transfer requested for £%s.'):format(Config.TransferFee))

    sendMenu(source)
end)
