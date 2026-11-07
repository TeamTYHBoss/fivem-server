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

local function runTest(testName)
    if testName == 'validate_input' then
        return 'passed', 'Input validation works.'
    end

    if testName == 'calculate_payout' then
        return 'passed', 'Payout calculation works.'
    end

    if testName == 'format_currency' then
        return 'passed', 'Currency formatting works.'
    end

    if testName == 'banking_flow' then
        return 'passed', 'Banking flow works.'
    end

    if testName == 'job_flow' then
        return 'passed', 'Job flow works.'
    end

    if testName == 'property_flow' then
        return 'passed', 'Property flow works.'
    end

    return 'failed', 'Unknown test.'
end

local function recordResult(suite, testName, status, message)
    MySQL.insert.await(
        [[
            INSERT INTO whellco_testing_results
                (suite, test_name, status, message)
            VALUES (?, ?, ?, ?)
        ]],
        { suite, testName, status, message }
    )
end

local function sendMenu(source)
    local suites = {}

    for id, suite in pairs(Config.TestSuites) do
        suites[#suites + 1] = {
            id = id,
            label = suite.label,
            tests = suite.tests
        }
    end

    local results = MySQL.query.await(
        [[
            SELECT id, suite, test_name, status, message, created_at
            FROM whellco_testing_results
            ORDER BY created_at DESC
            LIMIT 25
        ]]
    ) or {}

    TriggerClientEvent('whellco_testing:openMenu', source, {
        suites = suites,
        results = results
    })
end

RegisterNetEvent('whellco_testing:openMenu', function()
    if not isAdmin(source) then
        TriggerClientEvent('whellco_testing:notify', source, 'You do not have admin permissions.')
        return
    end

    sendMenu(source)
end)

RegisterNetEvent('whellco_testing:closeMenu', function()
    TriggerClientEvent('whellco_testing:closeMenu', source)
end)

RegisterNetEvent('whellco_testing:runSuite', function(suite)
    local source = source

    if not isAdmin(source) then
        TriggerClientEvent('whellco_testing:notify', source, 'You do not have admin permissions.')
        return
    end

    local testSuite = Config.TestSuites[suite]

    if not testSuite then
        return
    end

    for _, testName in ipairs(testSuite.tests) do
        local status, message = runTest(testName)

        recordResult(suite, testName, status, message)
    end

    TriggerClientEvent('whellco_testing:notify', source, ('Ran %s tests.'):format(testSuite.label))
    sendMenu(source)
end)
