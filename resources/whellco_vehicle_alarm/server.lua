local QBCore = exports['qb-core']:GetCoreObject()

local alarmCooldowns = {}

local function isPolice(Player)
    local job = Player.PlayerData.job

    return job and job.name == Config.PoliceJob
end

local function getPlayersInRadius(coords, radius)
    local players = QBCore.Functions.GetQBCorePlayers()
    local result = {}

    for _, Player in pairs(players) do
        local playerPed = GetPlayerPed(Player.PlayerData.source)
        local playerCoords = GetEntityCoords(playerPed)

        if #(playerCoords - coords) <= radius then
            result[#result + 1] = Player.PlayerData.source
        end
    end

    return result
end

RegisterNetEvent('whellco_vehicle_alarm:install', function(alarmType)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local alarm = Config.AlarmItems[alarmType]

    if not Player or not alarm then
        TriggerClientEvent('QBCore:Notify', source, 'Alarm type not found.', 'error')
        return
    end

    local playerPed = GetPlayerPed(source)
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle == 0 then
        TriggerClientEvent('QBCore:Notify', source, 'You must be in a vehicle.', 'error')
        return
    end

    local plate = QBCore.Shared.Trim(GetVehicleNumberPlateText(vehicle))

    if Player.Functions.GetMoney('cash') < alarm.price then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough cash.', 'error')
        return
    end

    Player.Functions.RemoveMoney('cash', alarm.price, ('Alarm installation: %s'):format(alarmType))

    MySQL.query.await(
        [[
            INSERT INTO whellco_vehicle_alarms
                (plate, alarm_type, armed)
            VALUES (?, ?, 1)
            ON DUPLICATE KEY UPDATE
                alarm_type = VALUES(alarm_type),
                armed = 1
        ]],
        { plate, alarmType }
    )

    TriggerClientEvent('QBCore:Notify', source, ('Installed %s for %s%d.'):format(alarm.label, Config.CurrencySymbol, alarm.price), 'success')
end)

RegisterNetEvent('whellco_vehicle_alarm:trigger', function(coords)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local playerPed = GetPlayerPed(source)
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle == 0 then
        return
    end

    local plate = QBCore.Shared.Trim(GetVehicleNumberPlateText(vehicle))
    local now = os.time()

    if now - (alarmCooldowns[source] or 0) < Config.AlarmCooldownSeconds then
        return
    end

    alarmCooldowns[source] = now

    local alarm = MySQL.single.await(
        [[
            SELECT id, alarm_type, armed
            FROM whellco_vehicle_alarms
            WHERE plate = ?
        ]],
        { plate }
    )

    if not alarm or alarm.armed ~= 1 then
        return
    end

    local alarmConfig = Config.AlarmItems[alarm.alarm_type]
    local duration = alarmConfig and alarmConfig.duration or Config.AlarmDuration

    local ownerAlerts = getPlayersInRadius(coords, Config.OwnerAlertRadius)
    local policeAlerts = getPlayersInRadius(coords, Config.PoliceAlertRadius)

    for _, targetSource in ipairs(ownerAlerts) do
        TriggerClientEvent('whellco_vehicle_alarm:ownerAlert', targetSource, {
            plate = plate,
            coords = coords,
            duration = duration
        })
    end

    for _, targetSource in ipairs(policeAlerts) do
        local targetPlayer = QBCore.Functions.GetPlayer(targetSource)

        if targetPlayer and isPolice(targetPlayer) then
            TriggerClientEvent('whellco_vehicle_alarm:policeAlert', targetSource, {
                plate = plate,
                coords = coords,
                duration = duration
            })
        end
    end
end)

RegisterCommand('installalarm', function(source, args)
    local alarmType = args[1]

    if not alarmType then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /installalarm [basic|advanced|premium]', 'error')
        return
    end

    TriggerEvent('whellco_vehicle_alarm:install', alarmType)
end, false)

RegisterCommand('triggeralarm', function()
    TriggerEvent('whellco_vehicle_alarm:trigger')
end, false)