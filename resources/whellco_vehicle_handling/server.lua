local QBCore = exports['qb-core']:GetCoreObject()

local function isMechanic(Player)
    local job = Player.PlayerData.job

    return job and Config.AllowedJobs[job.name] and (job.grade.level or 0) >= 0
end

local function getVehicleOwner(plate)
    return MySQL.single.await(
        [[
            SELECT citizenid
            FROM player_vehicles
            WHERE plate = ?
        ]],
        { plate }
    )
end

RegisterNetEvent('whellco_vehicle_handling:applyTuning', function(plate, category, level)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isMechanic(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have permission to tune vehicles.', 'error')
        return
    end

    plate = tostring(plate or ''):upper():gsub('%s', '')
    category = tostring(category or '')
    level = math.floor(tonumber(level) or 0)

    local maxLevel = Config.PerformanceLevels[category]
    local cost = Config.TuningCosts[category]

    if not maxLevel or not cost then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid tuning category.', 'error')
        return
    end

    if level < 0 or level > maxLevel then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid tuning level.', 'error')
        return
    end

    local owner = getVehicleOwner(plate)

    if not owner then
        TriggerClientEvent('QBCore:Notify', source, 'Vehicle not found.', 'error')
        return
    end

    local cost = cost * level

    if Player.Functions.GetMoney('bank') < cost then
        TriggerClientEvent('QBCore:Notify', source, ('Not enough money. Tuning costs $%d.'):format(cost), 'error')
        return
    end

    Player.Functions.RemoveMoney('bank', cost, 'Vehicle tuning')

    MySQL.query.await(
        [[
            INSERT INTO whellco_vehicle_tuning
                (plate, category, level)
            VALUES (?, ?, ?)
            ON DUPLICATE KEY UPDATE
                level = VALUES(level)
        ]],
        { plate, category, level }
    )

    TriggerClientEvent('whellco_vehicle_handling:applyTuning', source, {
        plate = plate,
        category = category,
        level = level
    })

    TriggerClientEvent('QBCore:Notify', source, ('Applied %s tuning level %d for $%d.'):format(category, level, cost), 'success')
end)

RegisterNetEvent('whellco_vehicle_handling:applyHandling', function(plate, profile)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isMechanic(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have permission to change vehicle handling.', 'error')
        return
    end

    plate = tostring(plate or ''):upper():gsub('%s', '')
    profile = tostring(profile or '')

    local handling = Config.HandlingProfiles[profile]

    if not handling then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid handling profile.', 'error')
        return
    end

    local owner = getVehicleOwner(plate)

    if not owner then
        TriggerClientEvent('QBCore:Notify', source, 'Vehicle not found.', 'error')
        return
    end

    MySQL.query.await(
        [[
            INSERT INTO whellco_vehicle_handling
                (plate, handling_profile)
            VALUES (?, ?)
            ON DUPLICATE KEY UPDATE
                handling_profile = VALUES(handling_profile)
        ]],
        { plate, profile }
    )

    TriggerClientEvent('whellco_vehicle_handling:applyHandling', source, {
        plate = plate,
        profile = profile,
        handling = handling
    })

    TriggerClientEvent('QBCore:Notify', source, ('Applied %s handling profile.'):format(handling.label), 'success')
end)

RegisterCommand('vehicletune', function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isMechanic(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have permission.', 'error')
        return
    end

    local plate = args[1]
    local category = args[2]
    local level = tonumber(args[3])

    if not plate or not category or not level then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /vehicletune [plate] [category] [level]', 'error')
        return
    end

    TriggerEvent('whellco_vehicle_handling:applyTuning', plate, category, level)
end, false)

RegisterCommand('vehiclehandling', function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isMechanic(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have permission.', 'error')
        return
    end

    local plate = args[1]
    local profile = args[2]

    if not plate or not profile then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /vehiclehandling [plate] [profile]', 'error')
        return
    end

    TriggerEvent('whellco_vehicle_handling:applyHandling', plate, profile)
end, false)