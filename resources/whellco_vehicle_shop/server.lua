local QBCore = exports['qb-core']:GetCoreObject()

local purchaseCooldowns = {}

local function generatePlate()
    local characters = {}

    for i = 1, 3 do
        characters[#characters + 1] = string.char(math.random(65, 90))
    end

    for i = 1, 3 do
        characters[#characters + 1] = tostring(math.random(0, 9))
    end

    return Config.VehiclePlatePrefix .. table.concat(characters)
end

local function isNear(coords, target, distance)
    return #(coords - target) <= distance
end

local function getVehicle(vehicleId)
    return Config.Vehicles[vehicleId]
end

RegisterNetEvent('whellco_vehicle_shop:purchase', function(dealershipId, vehicleId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local vehicle = getVehicle(vehicleId)
    local dealership = Config.Dealerships[dealershipId]

    if not Player or not vehicle or not dealership then
        TriggerClientEvent('QBCore:Notify', source, 'Vehicle or dealership not found.', 'error')
        return
    end

    if vehicle.dealership ~= dealershipId then
        TriggerClientEvent('QBCore:Notify', source, 'This vehicle is not sold here.', 'error')
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if not isNear(coords, dealership.location, 25.0) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not near the dealership.', 'error')
        return
    end

    local now = os.time()

    if now - (purchaseCooldowns[source] or 0) < Config.PurchaseCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before purchasing another vehicle.', 'error')
        return
    end

    local tax = math.floor(vehicle.price * (Config.TaxPercent / 100))
    local total = vehicle.price + tax

    if Player.Functions.GetMoney('bank') < total then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough money in your bank account.', 'error')
        return
    end

    local plate = generatePlate()

    Player.Functions.RemoveMoney('bank', total, ('Vehicle purchase: %s'):format(vehicleId))

    MySQL.insert.await(
        [[
            INSERT INTO player_vehicles
                (license, citizenid, vehicle, plate, garage, state)
            VALUES (?, ?, ?, ?, 'pillboxgarage', 0)
        ]],
        {
            Player.PlayerData.license,
            Player.PlayerData.citizenid,
            vehicle.model,
            plate
        }
    )

    purchaseCooldowns[source] = now

    TriggerClientEvent('whellco_vehicle_shop:vehiclePurchased', source, {
        model = vehicle.model,
        plate = plate,
        spawn = dealership.spawn
    })

    TriggerClientEvent('QBCore:Notify', source, ('Purchased %s for %s%d. Plate: %s'):format(vehicle.label, Config.CurrencySymbol, total, plate), 'success')
end)

RegisterCommand('vehicles', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local names = {}

    for id, vehicle in pairs(Config.Vehicles) do
        names[#names + 1] = ('%s - %s ($%d)'):format(id, vehicle.label, vehicle.price)
    end

    TriggerClientEvent('QBCore:Notify', source, table.concat(names, ', '), 'primary')
end, false)

RegisterCommand('buyvehicle', function(source, args)
    local dealershipId = args[1]
    local vehicleId = args[2]

    if not dealershipId or not vehicleId then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /buyvehicle [dealership] [vehicle]', 'error')
        return
    end

    TriggerEvent('whellco_vehicle_shop:purchase', dealershipId, vehicleId)
end, false)