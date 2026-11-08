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

local function recordRestore(restoreType, fileName, status, message)
    MySQL.insert.await(
        [[
            INSERT INTO whellco_restore_logs
                (restore_type, file_name, status, message)
            VALUES (?, ?, ?, ?)
        ]],
        { restoreType, fileName, status, message }
    )
end

local function sendMenu(source)
    local types = {}

    for id, label in pairs(Config.RestoreTypes) do
        types[#types + 1] = {
            id = id,
            label = label
        }
    end

    local logs = MySQL.query.await(
        [[
            SELECT id, restore_type, file_name, status, message, created_at
            FROM whellco_restore_logs
            ORDER BY created_at DESC
            LIMIT 25
        ]]
    ) or {}

    TriggerClientEvent('whellco_restore:openMenu', source, {
        types = types,
        logs = logs
    })
end

RegisterNetEvent('whellco_restore:openMenu', function()
    if not isAdmin(source) then
        TriggerClientEvent('whellco_restore:notify', source, 'You do not have admin permissions.')
        return
    end

    sendMenu(source)
end)

RegisterNetEvent('whellco_restore:closeMenu', function()
    TriggerClientEvent('whellco_restore:closeMenu', source)
end)

RegisterNetEvent('whellco_restore:requestRestore', function(restoreType, fileName)
    local source = source

    if not isAdmin(source) then
        TriggerClientEvent('whellco_restore:notify', source, 'You do not have admin permissions.')
        return
    end

    if not Config.RestoreTypes[restoreType] then
        return
    end

    if type(fileName) ~= 'string' or #fileName == 0 or #fileName > 255 then
        TriggerClientEvent('whellco_restore:notify', source, 'Invalid backup file name.')
        return
    end

    recordRestore(restoreType, fileName, 'queued', 'Restore requested from NUI.')

    TriggerClientEvent('whellco_restore:notify', source, 'Restore requested. Run the restore script on the host.')
    sendMenu(source)
end)
