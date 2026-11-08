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

local function recordBackup(backupType, fileName, status, message)
    MySQL.insert.await(
        [[
            INSERT INTO whellco_backup_logs
                (backup_type, file_name, status, message)
            VALUES (?, ?, ?, ?)
        ]],
        { backupType, fileName, status, message }
    )
end

local function sendMenu(source)
    local types = {}

    for id, label in pairs(Config.BackupTypes) do
        types[#types + 1] = {
            id = id,
            label = label
        }
    end

    local logs = MySQL.query.await(
        [[
            SELECT id, backup_type, file_name, status, message, created_at
            FROM whellco_backup_logs
            ORDER BY created_at DESC
            LIMIT 25
        ]]
    ) or {}

    TriggerClientEvent('whellco_backup:openMenu', source, {
        types = types,
        logs = logs
    })
end

RegisterNetEvent('whellco_backup:openMenu', function()
    if not isAdmin(source) then
        TriggerClientEvent('whellco_backup:notify', source, 'You do not have admin permissions.')
        return
    end

    sendMenu(source)
end)

RegisterNetEvent('whellco_backup:closeMenu', function()
    TriggerClientEvent('whellco_backup:closeMenu', source)
end)

RegisterNetEvent('whellco_backup:createBackup', function(backupType)
    local source = source

    if not isAdmin(source) then
        TriggerClientEvent('whellco_backup:notify', source, 'You do not have admin permissions.')
        return
    end

    if not Config.BackupTypes[backupType] then
        return
    end

    recordBackup(backupType, 'manual-backup', 'queued', 'Backup requested from NUI.')

    TriggerClientEvent('whellco_backup:notify', source, 'Backup requested. Run the backup script on the host.')
    sendMenu(source)
end)
