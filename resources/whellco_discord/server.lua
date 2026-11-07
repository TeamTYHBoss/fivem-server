local function getIdentifier(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')

    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'steam')
    end

    return identifier
end

local function sendDiscordLog(logType, message)
    MySQL.insert.await(
        [[
            INSERT INTO whellco_discord_logs
                (log_type, message)
            VALUES (?, ?)
        ]],
        { logType, message }
    )
end

local function sendMenu(source)
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local roles = {}

    for id, role in pairs(Config.DiscordRoles) do
        roles[#roles + 1] = {
            id = id,
            label = role.label,
            role_id = role.role_id
        }
    end

    local logs = MySQL.query.await(
        [[
            SELECT id, log_type, message, created_at
            FROM whellco_discord_logs
            ORDER BY created_at DESC
            LIMIT 25
        ]]
    ) or {}

    TriggerClientEvent('whellco_discord:openMenu', source, {
        roles = roles,
        logs = logs
    })
end

RegisterNetEvent('whellco_discord:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_discord:closeMenu', function()
    TriggerClientEvent('whellco_discord:closeMenu', source)
end)

RegisterNetEvent('whellco_discord:linkDiscord', function(discordId)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier or not discordId then
        return
    end

    MySQL.query.await(
        [[
            INSERT INTO whellco_discord_links
                (character_id, discord_id)
            VALUES (?, ?)
            ON DUPLICATE KEY UPDATE discord_id = VALUES(discord_id)
        ]],
        { identifier, discordId }
    )

    sendDiscordLog('link', ('Player %s linked Discord ID %s.'):format(identifier, discordId))

    TriggerClientEvent('whellco_discord:notify', source, 'Discord account linked.')
    sendMenu(source)
end)

RegisterNetEvent('whellco_discord:unlinkDiscord', function(discordId)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier or not discordId then
        return
    end

    MySQL.query.await(
        [[
            DELETE FROM whellco_discord_links
            WHERE character_id = ? AND discord_id = ?
        ]],
        { identifier, discordId }
    )

    sendDiscordLog('unlink', ('Player %s unlinked Discord ID %s.'):format(identifier, discordId))

    TriggerClientEvent('whellco_discord:notify', source, 'Discord account unlinked.')
    sendMenu(source)
end)

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    sendDiscordLog('join', ('Player %s connected.'):format(name))
end)

AddEventHandler('playerDropped', function(reason)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    sendDiscordLog('leave', ('Player %s disconnected: %s'):format(GetPlayerName(source), reason))
end)
