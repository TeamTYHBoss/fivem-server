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

    local impounds = MySQL.query.await(
        [[
            SELECT id, vehicle_id, owner_id, reason, release_fee, released, impounded_at
            FROM whellco_impounds
            WHERE owner_id = ? AND released = 0
            ORDER BY impounded_at DESC
        ]],
        { identifier }
    ) or {}

    TriggerClientEvent('whellco_impound:openMenu', source, {
        impounds = impounds
    })
end

RegisterNetEvent('whellco_impound:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_impound:closeMenu', function()
    TriggerClientEvent('whellco_impound:closeMenu', source)
end)

RegisterNetEvent('whellco_impound:releaseVehicle', function(impoundId)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local impound = MySQL.single.await(
        [[
            SELECT id, vehicle_id, owner_id, reason, release_fee, released
            FROM whellco_impounds
            WHERE id = ? AND owner_id = ? AND released = 0
            LIMIT 1
        ]],
        { impoundId, identifier }
    )

    if not impound then
        return
    end

    MySQL.query.await(
        [[
            UPDATE whellco_impounds
            SET released = 1, released_at = NOW()
            WHERE id = ?
        ]],
        { impound.id }
    )

    TriggerClientEvent('whellco_impound:notify', source, ('Vehicle released from impound for £%s.'):format(impound.release_fee))

    sendMenu(source)
end)
