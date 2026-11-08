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

    local collisions = MySQL.query.await(
        [[
            SELECT id, vehicle_id, owner_id, collision_type, damage, repair_cost, repaired, created_at
            FROM whellco_collisions
            WHERE owner_id = ? AND repaired = 0
            ORDER BY created_at DESC
        ]],
        { identifier }
    ) or {}

    TriggerClientEvent('whellco_collision:openMenu', source, {
        collisions = collisions
    })
end

RegisterNetEvent('whellco_collision:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_collision:closeMenu', function()
    TriggerClientEvent('whellco_collision:closeMenu', source)
end)

RegisterNetEvent('whellco_collision:repairVehicle', function(collisionId)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local collision = MySQL.single.await(
        [[
            SELECT id, vehicle_id, owner_id, collision_type, damage, repair_cost, repaired
            FROM whellco_collisions
            WHERE id = ? AND owner_id = ? AND repaired = 0
            LIMIT 1
        ]],
        { collisionId, identifier }
    )

    if not collision then
        return
    end

    MySQL.query.await(
        [[
            UPDATE whellco_collisions
            SET repaired = 1, repaired_at = NOW()
            WHERE id = ?
        ]],
        { collision.id }
    )

    TriggerClientEvent('whellco_collision:notify', source, ('Vehicle repaired for £%s.'):format(collision.repair_cost))

    sendMenu(source)
end)
