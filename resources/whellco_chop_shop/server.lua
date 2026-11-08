local QBCore = exports['qb-core']:GetCoreObject()

local chopCooldowns = {}

local function isNear(coords, shop)
    return #(coords - shop.location) <= shop.radius
end

local function isStolen(plate)
    local count = MySQL.scalar.await(
        [[
            SELECT COUNT(*)
            FROM whellco_stolen_vehicles
            WHERE plate = ?
              AND status = 'stolen'
        ]],
        { plate }
    )

    return count and count > 0
end

local function getVehicle(plate)
    return MySQL.single.await(
        [[
            SELECT id, citizenid, vehicle, plate
            FROM player_vehicles
            WHERE plate = ?
        ]],
        { plate }
    )
end

RegisterNetEvent('whellco_chop_shop:chop', function(parts)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    if type(parts) ~= 'table' or #parts == 0 then
        TriggerClientEvent('QBCore:Notify', source, 'Select at least one vehicle part.', 'error')
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if not isNear(coords, Config.ChopShop) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not at the chop shop.', 'error')
        return
    end

    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle == 0 then
        TriggerClientEvent('QBCore:Notify', source, 'You must be in a vehicle.', 'error')
        return
    end

    local plate = QBCore.Shared.Trim(GetVehicleNumberPlateText(vehicle))
    local vehicleData = getVehicle(plate)

    if vehicleData then
        TriggerClientEvent('QBCore:Notify', source, 'This vehicle is not eligible for chopping.', 'error')
        return
    end

    local now = os.time()

    if now - (chopCooldowns[source] or 0) < Config.ChopCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before chopping another vehicle.', 'error')
        return
    end

    local total = 0

    for _, part in ipairs(parts) do
        local value = Config.PartValues[part]

        if value then
            total = total + value
        end
    end

    if total < Config.MinVehicleValue then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough valuable parts selected.', 'error')
        return
    end

    if isStolen(plate) then
        total = math.floor(total * Config.StolenVehicleBonus)
    end

    Player.Functions.AddItem('scrapmetal', math.max(1, math.floor(total / 500)))
    Player.Functions.AddMoney('cash', total, 'Chop shop sale')

    chopCooldowns[source] = now

    TriggerClientEvent('whellco_chop_shop:chopped', source, {
        plate = plate,
        total = total,
        parts = parts
    })

    TriggerClientEvent('QBCore:Notify', source, ('Chopped vehicle for %s%d.'):format(Config.CurrencySymbol, total), 'success')
end)

RegisterCommand('chopvehicle', function(source, args)
    local parts = {}

    for i = 2, #args do
        parts[#parts + 1] = args[i]
    end

    if #parts == 0 then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /chopvehicle [stolen] [part1] [part2]', 'error')
        return
    end

    TriggerEvent('whellco_chop_shop:chop', parts)
end, false)