local function getIdentifier(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')

    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'steam')
    end

    return identifier
end

local function isAdmin(source)
    local identifier = getIdentifier(source)

    if not identifier then
        return false
    end

    return IsPlayerAceAllowed(source, 'whellco.admin')
end

local function sendMenu(source)
    local players = {}

    for _, playerId in ipairs(GetPlayers()) do
        local identifier = getIdentifier(playerId)

        players[#players + 1] = {
            id = playerId,
            name = GetPlayerName(playerId),
            identifier = identifier
        }
    end

    local bans = MySQL.query.await(
        [[
            SELECT id, identifier, reason, banned_by, banned_at, expires_at
            FROM whellco_admin_bans
            ORDER BY banned_at DESC
            LIMIT 25
        ]]
    ) or {}

    local actions = MySQL.query.await(
        [[
            SELECT id, admin_id, target_id, action_type, reason, created_at
            FROM whellco_admin_actions
            ORDER BY created_at DESC
            LIMIT 25
        ]]
    ) or {}

    TriggerClientEvent('whellco_admin:openMenu', source, {
        players = players,
        bans = bans,
        actions = actions
    })
end

RegisterNetEvent('whellco_admin:openMenu', function()
    if not isAdmin(source) then
        TriggerClientEvent('whellco_admin:notify', source, 'You do not have admin permissions.')
        return
    end

    sendMenu(source)
end)

RegisterNetEvent('whellco_admin:closeMenu', function()
    TriggerClientEvent('whellco_admin:closeMenu', source)
end)

RegisterNetEvent('whellco_admin:kickPlayer', function(targetId, reason)
    local source = source

    if not isAdmin(source) then
        TriggerClientEvent('whellco_admin:notify', source, 'You do not have admin permissions.')
        return
    end

    local adminId = getIdentifier(source)
    local target = GetPlayerFromServerId(targetId)

    if target == 0 then
        return
    end

    local targetId2 = getIdentifier(target)

    if not adminId or not targetId2 then
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_admin_actions
                (admin_id, target_id, action_type, reason)
            VALUES (?, ?, 'kick', ?)
        ]],
        { adminId, targetId2, reason or 'No reason provided' }
    )

    DropPlayer(target, reason or 'You have been kicked by an administrator.')
end)

RegisterNetEvent('whellco_admin:banPlayer', function(targetId, reason)
    local source = source

    if not isAdmin(source) then
        TriggerClientEvent('whellco_admin:notify', source, 'You do not have admin permissions.')
        return
    end

    local adminId = getIdentifier(source)
    local target = GetPlayerFromServerId(targetId)

    if target == 0 then
        return
    end

    local targetId2 = getIdentifier(target)

    if not adminId or not targetId2 then
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_admin_bans
                (identifier, reason, banned_by)
            VALUES (?, ?, ?)
        ]],
        { targetId2, reason or 'No reason provided', adminId }
    )

    MySQL.insert.await(
        [[
            INSERT INTO whellco_admin_actions
                (admin_id, target_id, action_type, reason)
            VALUES (?, ?, 'ban', ?)
        ]],
        { adminId, targetId2, reason or 'No reason provided' }
    )

    DropPlayer(target, reason or 'You have been banned by an administrator.')
end)

RegisterNetEvent('whellco_admin:unbanPlayer', function(banId)
    local source = source

    if not isAdmin(source) then
        TriggerClientEvent('whellco_admin:notify', source, 'You do not have admin permissions.')
        return
    end

    MySQL.query.await(
        [[
            DELETE FROM whellco_admin_bans
            WHERE id = ?
        ]],
        { banId }
    )

    TriggerClientEvent('whellco_admin:notify', source, 'Ban removed.')
    sendMenu(source)
end)

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local ban = MySQL.single.await(
        [[
            SELECT id, reason, expires_at
            FROM whellco_admin_bans
            WHERE identifier = ?
            LIMIT 1
        ]],
        { identifier }
    )

    if not ban then
        return
    end

    if ban.expires_at and os.time() > ban.expires_at then
        return
    end

    deferrals.done(('You are banned: %s'):format(ban.reason))
end)
