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

local function recordReview(checkName, status, message)
    MySQL.insert.await(
        [[
            INSERT INTO whellco_polish_reviews
                (check_name, status, message)
            VALUES (?, ?, ?)
        ]],
        { checkName, status, message }
    )
end

local function sendMenu(source)
    local checks = {}

    for id, label in pairs(Config.PolishChecks) do
        checks[#checks + 1] = {
            id = id,
            label = label,
            status = 'pending'
        }
    end

    local reviews = MySQL.query.await(
        [[
            SELECT id, check_name, status, message, created_at
            FROM whellco_polish_reviews
            ORDER BY created_at DESC
            LIMIT 25
        ]]
    ) or {}

    TriggerClientEvent('whellco_polish:openMenu', source, {
        checks = checks,
        reviews = reviews
    })
end

RegisterNetEvent('whellco_polish:openMenu', function()
    if not isAdmin(source) then
        TriggerClientEvent('whellco_polish:notify', source, 'You do not have admin permissions.')
        return
    end

    sendMenu(source)
end)

RegisterNetEvent('whellco_polish:closeMenu', function()
    TriggerClientEvent('whellco_polish:closeMenu', source)
end)

RegisterNetEvent('whellco_polish:runReview', function()
    local source = source

    if not isAdmin(source) then
        TriggerClientEvent('whellco_polish:notify', source, 'You do not have admin permissions.')
        return
    end

    for id, label in pairs(Config.PolishChecks) do
        recordReview(id, 'reviewed', ('%s reviewed.'):format(label))
    end

    TriggerClientEvent('whellco_polish:notify', source, 'Final review completed.')
    sendMenu(source)
end)
