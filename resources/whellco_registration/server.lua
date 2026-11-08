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

    local registrations = MySQL.query.await(
        [[
            SELECT id, vehicle_id, owner_id, plate, registered, registered_at, created_at
            FROM whellco_vehicle_registrations
            WHERE owner_id = ?
            ORDER BY created_at DESC
        ]],
        { identifier }
    ) or {}

    local transfers = MySQL.query.await(
        [[
            SELECT id, vehicle_id, from_owner_id, to_owner_id, transfer_fee, transferred_at
            FROM whellco_vehicle_transfers
            WHERE from_owner_id = ? OR to_owner_id = ?
            ORDER BY transferred_at DESC
            LIMIT 25
        ]],
        { identifier, identifier }
    ) or {}

    TriggerClientEvent('whellco_registration:openMenu', source, {
        vehicles = vehicles,
        registrations = registrations,
        transfers = transfers
    })
end

RegisterNetEvent('whellco_registration:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_registration:closeMenu', function()
    TriggerClientEvent('whellco_registration:closeMenu', source)
end)

RegisterNetEvent('whellco_registration:registerVehicle', function(vehicleId, plate)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    if type(plate) ~= 'string' or #plate == 0 or #plate > 8 then
        TriggerClientEvent('whellco_registration:notify', source, 'Invalid plate.')
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
            INSERT INTO whellco_vehicle_registrations
                (vehicle_id, owner_id, plate, registered, registered_at)
            VALUES (?, ?, ?, 1, CURRENT_TIMESTAMP)
            ON DUPLICATE KEY UPDATE plate = VALUES(plate), registered = 1, registered_at = CURRENT_TIMESTAMP
        ]],
        { vehicleId, identifier, plate }
    )

    TriggerClientEvent('whellco_registration:notify', source, ('Vehicle registered with plate %s for £%s.'):format(plate, Config.RegistrationFee))
    sendMenu(source)
end)

RegisterNetEvent('whellco_registration:transferVehicle', function(vehicleId, targetId)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local target = GetPlayerFromServerId(targetId)

    if target == 0 then
        return
    end

    local targetIdentifier = getIdentifier(target)

    if not targetIdentifier then
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

    MySQL.transaction.await({
        {
            query = [[
                UPDATE whellco_vehicles
                SET owner_id = ?
                WHERE id = ? AND owner_id = ?
            ]],
            values = { targetIdentifier, vehicleId, identifier }
        },
        {
            query = [[
                INSERT INTO whellco_vehicle_transfers
                    (vehicle_id, from_owner_id, to_owner_id, transfer_fee)
                VALUES (?, ?, ?, ?)
            ]],
            values = { vehicleId, identifier, targetIdentifier, Config.TransferFee }
        },
        {
            query = [[
                UPDATE whellco_vehicle_registrations
                SET owner_id = ?
                WHERE vehicle_id = ?
            ]],
            values = { targetIdentifier, vehicleId }
        }
    })

    TriggerClientEvent('whellco_registration:notify', source, 'Vehicle transferred.')
    TriggerClientEvent('whellco_registration:notify', target, 'You received a vehicle transfer.')
    sendMenu(source)
end)
