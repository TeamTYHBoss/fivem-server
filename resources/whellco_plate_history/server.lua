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

    local history = MySQL.query.await(
        [[
            SELECT id, vehicle_id, owner_id, old_plate, new_plate, changed_at
            FROM whellco_plate_history
            WHERE owner_id = ?
            ORDER BY changed_at DESC
            LIMIT ?
        ]],
        { identifier, Config.MaxHistoryEntries }
    ) or {}

    TriggerClientEvent('whellco_plate_history:openMenu', source, {
        history = history
    })
end

RegisterNetEvent('whellco_plate_history:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_plate_history:closeMenu', function()
    TriggerClientEvent('whellco_plate_history:closeMenu', source)
end)

RegisterNetEvent('whellco_plate_history:recordChange', function(vehicleId, oldPlate, newPlate)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    oldPlate = tostring(oldPlate or ''):upper():gsub('^%s*(.-)%s*$', '%1')
    newPlate = tostring(newPlate or ''):upper():gsub('^%s*(.-)%s*$', '%1')

    if oldPlate == newPlate then
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_plate_history
                (vehicle_id, owner_id, old_plate, new_plate)
            VALUES (?, ?, ?, ?)
        ]],
        { vehicleId, identifier, oldPlate, newPlate }
    )

    TriggerClientEvent('whellco_plate_history:notify', source, ('Plate changed from %s to %s.'):format(oldPlate, newPlate))

    sendMenu(source)
end)
