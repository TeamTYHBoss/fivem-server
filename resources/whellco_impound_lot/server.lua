local QBCore = exports['qb-core']:GetCoreObject()

local releaseCooldowns = {}

local function isPolice(Player)
    local job = Player.PlayerData.job

    return job and job.name == Config.PoliceJob
end

local function isNear(coords, location)
    return #(coords - location) <= 20.0
end

local function getUnpaidPoints(citizenid)
    local total = MySQL.scalar.await(
        [[
            SELECT COALESCE(SUM(points), 0)
            FROM whellco_traffic_fines
            WHERE citizenid = ?
              AND status = 'unpaid'
        ]],
        { citizenid }
    )

    return tonumber(total) or 0
end

local function getVehicle(plate)
    return MySQL.single.await(
        [[
            SELECT id, citizenid, vehicle, plate, state
            FROM player_vehicles
            WHERE plate = ?
        ]],
        { plate }
    )
end

RegisterNetEvent('whellco_impound_lot:impound', function(plate, reason)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isPolice(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not authorised to impound vehicles.', 'error')
        return
    end

    if type(plate) ~= 'string' or plate == '' then
        TriggerClientEvent('QBCore:Notify', source, 'Provide a valid plate.', 'error')
        return
    end

    local vehicle = getVehicle(plate)

    if not vehicle then
        TriggerClientEvent('QBCore:Notify', source, 'Vehicle not found.', 'error')
        return
    end

    local points = getUnpaidPoints(vehicle.citizenid)

    if points < Config.MinUnpaidPoints then
        TriggerClientEvent('QBCore:Notify', source, ('Owner does not have enough unpaid points. Required: %d.'):format(Config.MinUnpaidPoints), 'error')
        return
    end

    MySQL.update.await(
        [[
            UPDATE player_vehicles
            SET state = 2
            WHERE plate = ?
        ]],
        { plate }
    )

    MySQL.query.await(
        [[
            INSERT INTO whellco_impound_records
                (plate, owner_citizenid, officer_citizenid, reason, status)
            VALUES (?, ?, ?, ?, 'impounded')
        ]],
        {
            plate,
            vehicle.citizenid,
            Player.PlayerData.citizenid,
            reason or ('Impounded for %d unpaid point(s).'):format(points)
        }
    )

    TriggerClientEvent('QBCore:Notify', source, ('Impounded vehicle %s.'):format(plate), 'success')
end)

RegisterNetEvent('whellco_impound_lot:release', function(plate)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    if type(plate) ~= 'string' or plate == '' then
        TriggerClientEvent('QBCore:Notify', source, 'Provide a valid plate.', 'error')
        return
    end

    local vehicle = getVehicle(plate)

    if not vehicle or vehicle.citizenid ~= Player.PlayerData.citizenid then
        TriggerClientEvent('QBCore:Notify', source, 'You do not own this vehicle.', 'error')
        return
    end

    local record = MySQL.single.await(
        [[
            SELECT id, status
            FROM whellco_impound_records
            WHERE plate = ?
            ORDER BY created_at DESC
            LIMIT 1
        ]],
        { plate }
    )

    if not record or record.status ~= 'impounded' then
        TriggerClientEvent('QBCore:Notify', source, 'This vehicle is not impounded.', 'error')
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if not isNear(coords, Config.ImpoundLot.location) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not at the impound lot.', 'error')
        return
    end

    local now = os.time()

    if now - (releaseCooldowns[source] or 0) < Config.ReleaseCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before releasing another vehicle.', 'error')
        return
    end

    local points = getUnpaidPoints(Player.PlayerData.citizenid)

    if points >= Config.MinUnpaidPoints then
        TriggerClientEvent('QBCore:Notify', source, ('Pay unpaid fines first. You have %d unpaid point(s).'):format(points), 'error')
        return
    end

    if Player.Functions.GetMoney('bank') < Config.ImpoundFee then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough money in your bank account.', 'error')
        return
    end

    Player.Functions.RemoveMoney('bank', Config.ImpoundFee, ('Impound release: %s'):format(plate))

    MySQL.update.await(
        [[
            UPDATE player_vehicles
            SET state = 0
            WHERE plate = ?
        ]],
        { plate }
    )

    MySQL.update.await(
        [[
            UPDATE whellco_impound_records
            SET status = 'released',
                released_at = CURRENT_TIMESTAMP
            WHERE id = ?
        ]],
        { record.id }
    )

    releaseCooldowns[source] = now

    TriggerClientEvent('whellco_impound_lot:release', source, {
        plate = plate,
        spawn = Config.ImpoundLot.releasePoint
    })

    TriggerClientEvent('QBCore:Notify', source, ('Released %s for %s%d.'):format(plate, Config.CurrencySymbol, Config.ImpoundFee), 'success')
end)

RegisterCommand('impound', function(source, args)
    local plate = args[1]
    local reason = table.concat(args, ' ', 2)

    if not plate then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /impound [plate] [reason]', 'error')
        return
    end

    TriggerEvent('whellco_impound_lot:impound', plate, reason)
end, false)

RegisterCommand('releasevehicle', function(source, args)
    local plate = args[1]

    if not plate then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /releasevehicle [plate]', 'error')
        return
    end

    TriggerEvent('whellco_impound_lot:release', plate)
end, false)