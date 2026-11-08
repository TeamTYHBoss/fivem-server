local QBCore = exports['qb-core']:GetCoreObject()

local refuelCooldowns = {}

local function isNear(coords, station)
    return #(coords - station.location) <= station.radius
end

local function getFuelLevel(plate)
    local row = MySQL.single.await(
        [[
            SELECT fuel
            FROM whellco_vehicle_fuel
            WHERE plate = ?
        ]],
        { plate }
    )

    if row and row.fuel then
        return tonumber(row.fuel) or 0.0
    end

    return Config.StartingFuel
end

local function saveFuelLevel(plate, fuel)
    MySQL.query.await(
        [[
            INSERT INTO whellco_vehicle_fuel
                (plate, fuel)
            VALUES (?, ?)
            ON DUPLICATE KEY UPDATE
                fuel = VALUES(fuel)
        ]],
        { plate, fuel }
    )
end

local function ownsVehicle(Player, plate)
    local count = MySQL.scalar.await(
        [[
            SELECT COUNT(*)
            FROM player_vehicles
            WHERE citizenid = ?
              AND plate = ?
        ]],
        { Player.PlayerData.citizenid, plate }
    )

    return count and count > 0
end

RegisterNetEvent('whellco_fuel_station:refuel', function(stationId, litres)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local station = Config.GasStations[stationId]

    if not Player or not station then
        return
    end

    litres = math.floor(tonumber(litres) or 0)

    if litres <= 0 then
        TriggerClientEvent('QBCore:Notify', source, 'Enter a valid fuel amount.', 'error')
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if not isNear(coords, station) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not near a gas station.', 'error')
        return
    end

    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle == 0 then
        TriggerClientEvent('QBCore:Notify', source, 'You must be in a vehicle.', 'error')
        return
    end

    local plate = QBCore.Shared.Trim(GetVehicleNumberPlateText(vehicle))

    if not ownsVehicle(Player, plate) then
        TriggerClientEvent('QBCore:Notify', source, 'You do not own this vehicle.', 'error')
        return
    end

    local now = os.time()

    if now - (refuelCooldowns[source] or 0) < Config.RefuelCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before refuelling again.', 'error')
        return
    end

    local currentFuel = getFuelLevel(plate)
    local space = Config.MaxFuelLevel - currentFuel

    if space <= 0 then
        TriggerClientEvent('QBCore:Notify', source, 'The vehicle tank is already full.', 'error')
        return
    end

    if litres > space then
        litres = math.floor(space)
    end

    local cost = math.floor(litres * Config.FuelPricePerLitre)

    if Player.Functions.GetMoney('cash') < cost then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough cash.', 'error')
        return
    end

    Player.Functions.RemoveMoney('cash', cost, ('Fuel purchase: %s'):format(station.label))

    local newFuel = math.min(Config.MaxFuelLevel, currentFuel + litres)

    saveFuelLevel(plate, newFuel)

    refuelCooldowns[source] = now

    TriggerClientEvent('whellco_fuel_station:setFuel', source, newFuel)
    TriggerClientEvent('QBCore:Notify', source, ('Refuelled %dL for %s%d.'):format(litres, Config.CurrencySymbol, cost), 'success')
end)

RegisterNetEvent('whellco_fuel_station:checkFuel', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local playerPed = GetPlayerPed(source)
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if not Player or vehicle == 0 then
        return
    end

    local plate = QBCore.Shared.Trim(GetVehicleNumberPlateText(vehicle))
    local fuel = getFuelLevel(plate)

    TriggerClientEvent('whellco_fuel_station:setFuel', source, fuel)
end)

RegisterCommand('fuel', function(source, args)
    local stationId = args[1]
    local litres = tonumber(args[2])

    if not stationId or not litres then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /fuel [station] [litres]', 'error')
        return
    end

    TriggerEvent('whellco_fuel_station:refuel', stationId, litres)
end, false)

RegisterCommand('checkfuel', function()
    TriggerEvent('whellco_fuel_station:checkFuel')
end, false)