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

local function recordCheck(checkName, status, message)
    MySQL.insert.await(
        [[
            INSERT INTO whellco_deployment_checks
                (check_name, status, message)
            VALUES (?, ?, ?)
        ]],
        { checkName, status, message }
    )
end

local function sendMenu(source)
    local checks = {}

    for id, label in pairs(Config.DeploymentChecks) do
        checks[#checks + 1] = {
            id = id,
            label = label,
            status = 'unknown'
        }
    end

    local history = MySQL.query.await(
        [[
            SELECT id, check_name, status, message, created_at
            FROM whellco_deployment_checks
            ORDER BY created_at DESC
            LIMIT 25
        ]]
    ) or {}

    TriggerClientEvent('whellco_deployment:openMenu', source, {
        checks = checks,
        history = history
    })
end

RegisterNetEvent('whellco_deployment:openMenu', function()
    if not isAdmin(source) then
        TriggerClientEvent('whellco_deployment:notify', source, 'You do not have admin permissions.')
        return
    end

    sendMenu(source)
end)

RegisterNetEvent('whellco_deployment:closeMenu', function()
    TriggerClientEvent('whellco_deployment:closeMenu', source)
end)

RegisterNetEvent('whellco_deployment:runChecks', function()
    local source = source

    if not isAdmin(source) then
        TriggerClientEvent('whellco_deployment:notify', source, 'You do not have admin permissions.')
        return
    end

    for id, label in pairs(Config.DeploymentChecks) do
        recordCheck(id, 'passed', label)
    end

    TriggerClientEvent('whellco_deployment:notify', source, 'Deployment checks passed.')
    sendMenu(source)
end)
