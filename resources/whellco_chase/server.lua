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

    local chases = MySQL.query.await(
        [[
            SELECT id, vehicle_id, owner_id, reason, started_at, ended_at, active
            FROM whellco_chases
            WHERE owner_id = ? AND active = 1
            ORDER BY started_at DESC
        ]],
        { identifier }
    ) or {}

    TriggerClientEvent('whellco_chase:openMenu', source, {
        chases = chases
    })
end

RegisterNetEvent('whellco_chase:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_chase:closeMenu', function()
    TriggerClientEvent('whellco_chase:closeMenu', source)
end)

RegisterNetEvent('whellco_chase:endChase', function(chaseId)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local chase = MySQL.single.await(
        [[
            SELECT id, vehicle_id, owner_id, reason, active
            FROM whellco_chases
            WHERE id = ? AND owner_id = ? AND active = 1
            LIMIT 1
        ]],
        { chaseId, identifier }
    )

    if not chase then
        return
    end

    MySQL.query.await(
        [[
            UPDATE whellco_chases
            SET active = 0, ended_at = NOW()
            WHERE id = ?
        ]],
        { chase.id }
    )

    TriggerClientEvent('whellco_chase:notify', source, 'Chase ended.')

    sendMenu(source)
end)
