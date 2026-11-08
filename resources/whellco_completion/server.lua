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
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local steps = {}

    for id, label in pairs(Config.CompletionSteps) do
        steps[#steps + 1] = {
            id = id,
            label = label,
            completed = false
        }
    end

    local records = MySQL.query.await(
        [[
            SELECT id, step, completed, completed_at, created_at
            FROM whellco_completion_records
            WHERE character_id = ?
        ]],
        { identifier }
    ) or {}

    TriggerClientEvent('whellco_completion:openMenu', source, {
        steps = steps,
        records = records
    })
end

RegisterNetEvent('whellco_completion:openMenu', function()
    if not isAdmin(source) then
        TriggerClientEvent('whellco_completion:notify', source, 'You do not have admin permissions.')
        return
    end

    sendMenu(source)
end)

RegisterNetEvent('whellco_completion:closeMenu', function()
    TriggerClientEvent('whellco_completion:closeMenu', source)
end)

RegisterNetEvent('whellco_completion:completeStep', function(step)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    if not isAdmin(source) then
        TriggerClientEvent('whellco_completion:notify', source, 'You do not have admin permissions.')
        return
    end

    if not Config.CompletionSteps[step] then
        return
    end

    MySQL.query.await(
        [[
            INSERT INTO whellco_completion_records
                (character_id, step, completed, completed_at)
            VALUES (?, ?, 1, CURRENT_TIMESTAMP)
            ON DUPLICATE KEY UPDATE completed = 1, completed_at = CURRENT_TIMESTAMP
        ]],
        { identifier, step }
    )

    TriggerClientEvent('whellco_completion:notify', source, ('Completed %s.'):format(Config.CompletionSteps[step]))
    sendMenu(source)
end)
