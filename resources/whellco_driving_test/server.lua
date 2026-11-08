local QBCore = exports['qb-core']:GetCoreObject()

local activeTests = {}
local testCooldowns = {}

local function isNear(coords, center)
    return #(coords - center.location) <= center.radius
end

local function hasPassedTest(Player)
    local count = MySQL.scalar.await(
        [[
            SELECT COUNT(*)
            FROM whellco_driving_tests
            WHERE citizenid = ?
              AND passed = 1
        ]],
        { Player.PlayerData.citizenid }
    )

    return count and count > 0
end

RegisterNetEvent('whellco_driving_test:start', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if not isNear(coords, Config.TestCenter) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not at the DMV driving test center.', 'error')
        return
    end

    if hasPassedTest(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You have already passed the driving test.', 'error')
        return
    end

    local now = os.time()

    if now - (testCooldowns[source] or 0) < Config.TestCooldownMinutes * 60 then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before taking another driving test.', 'error')
        return
    end

    if Player.Functions.GetMoney('cash') < 250 then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough cash.', 'error')
        return
    end

    Player.Functions.RemoveMoney('cash', 250, 'Practical driving test')

    activeTests[source] = {
        startedAt = now,
        fails = 0,
        currentCheckpoint = 1
    }

    TriggerClientEvent('whellco_driving_test:start', source, {
        vehicle = Config.TestVehicle,
        spawn = Config.TestCenter.vehicleSpawn,
        checkpoints = Config.Checkpoints,
        maxSpeed = Config.MaxSpeedKmh
    })
end)

RegisterNetEvent('whellco_driving_test:penalty', function(reason)
    local source = source
    local test = activeTests[source]

    if not test then
        return
    end

    test.fails = test.fails + 1

    if test.fails >= Config.MaxFails then
        activeTests[source] = nil
        testCooldowns[source] = os.time()

        MySQL.query.await(
            [[
                INSERT INTO whellco_driving_tests
                    (citizenid, score, passed, reason)
                VALUES (?, 0, 0, ?)
            ]],
            { QBCore.Functions.GetPlayer(source).PlayerData.citizenid, reason or 'Too many penalties' }
        )

        TriggerClientEvent('whellco_driving_test:end', source, {
            passed = false,
            reason = reason or 'Too many penalties'
        })
    end
end)

RegisterNetEvent('whellco_driving_test:complete', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local test = activeTests[source]

    if not Player or not test then
        return
    end

    activeTests[source] = nil
    testCooldowns[source] = os.time()

    MySQL.query.await(
        [[
            INSERT INTO whellco_driving_tests
                (citizenid, score, passed, reason)
            VALUES (?, 100, 1, 'Completed all checkpoints')
        ]],
        { Player.PlayerData.citizenid }
    )

    TriggerClientEvent('whellco_driving_test:end', source, {
        passed = true,
        reason = 'Completed all checkpoints'
    })
end)

RegisterCommand('drivingtest', function()
    TriggerEvent('whellco_driving_test:start')
end, false)

RegisterCommand('drivingtestinfo', function()
    TriggerEvent('whellco_driving_test:info')
end, false)