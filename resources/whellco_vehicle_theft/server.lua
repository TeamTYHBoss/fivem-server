local QBCore = exports['qb-core']:GetCoreObject()

local hotwireCooldowns = {}
local theftAlertCooldowns = {}

local function isPolice(Player)
    local job = Player.PlayerData.job

    return job and job.name == Config.PoliceJob
end

local function getPolicePlayers()
    local players = QBCore.Functions.GetQBCorePlayers()
    local police = {}

    for _, Player in pairs(players) do
        if isPolice(Player) then
            police[#police + 1] = Player.PlayerData.source
        end
    end

    return police
end

RegisterNetEvent('whellco_vehicle_theft:hotwire', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local now = os.time()

    if now - (hotwireCooldowns[source] or 0) < Config.HotwireCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before hotwiring again.', 'error')
        return
    end

    local lockpick = Player.Functions.GetItemByName(Config.RequiredItem)

    if not lockpick or lockpick.amount < 1 then
        TriggerClientEvent('QBCore:Notify', source, 'You need a lockpick.', 'error')
        return
    end

    hotwireCooldowns[source] = now

    TriggerClientEvent('whellco_vehicle_theft:startHotwire', source, {
        duration = Config.HotwireTime
    })
end)

RegisterNetEvent('whellco_vehicle_theft:complete', function(coords)
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

    if now - (theftAlertCooldowns[source] or 0) < Config.TheftAlertCooldownSeconds then
        return
    end

    theftAlertCooldowns[source] = now

    MySQL.query.await(
        [[
            INSERT INTO whellco_stolen_vehicles
                (plate, model, owner_citizenid, thief_citizenid, status)
            VALUES (?, ?, NULL, ?, 'stolen')
        ]],
        {
            plate,
            GetEntityModel(vehicle),
            Player.PlayerData.citizenid
        }
    )

    local police = getPolicePlayers()

    for _, policeSource in ipairs(police) do
        TriggerClientEvent('whellco_vehicle_theft:alert', policeSource, {
            thiefSource = source,
            thiefName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
            plate = plate,
            coords = coords
        })
    end

    TriggerClientEvent('QBCore:Notify', source, 'Vehicle hotwired.', 'success')
end)

RegisterCommand('hotwire', function()
    TriggerEvent('whellco_vehicle_theft:hotwire')
end, false)