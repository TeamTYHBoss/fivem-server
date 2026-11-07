local activeVehicles = {}

local function getIdentifier(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')

    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'steam')
    end

    return identifier
end

local function generatePlate()
    local characters = 'ABCDEFGHJKLMNPRSTUVWXYZ0123456789'
    local plate = ''

    for _ = 1, 8 do
        local index = math.random(1, #characters)
        plate = plate .. characters:sub(index, index)
    end

    return plate
end

local function getOwnedVehicles(characterId)
    return MySQL.query.await(
        'SELECT id, model, plate, stored, garage FROM whellco_vehicles WHERE character_id = ? ORDER BY created_at DESC',
        { characterId }
    ) or {}
end

RegisterNetEvent('whellco_vehicles:openGarage', function(garageId)
    local source = source
    local garage = Config.Garages[garageId]

    if not garage then
        return
    end

    local ped = GetPlayerPed(source)

    if #(GetEntityCoords(ped) - garage.coords) > 10.0 then
        return
    end

    local characterId = GetPlayerIdentifierByType(source, 'license')

    if not characterId then
        return
    end

    local vehicles = getOwnedVehicles(characterId)
    local owned = {}

    for _, vehicle in ipairs(vehicles) do
        if vehicle.stored == 1 then
            owned[#owned + 1] = vehicle
        end
    end

    TriggerClientEvent('whellco_vehicles:openGarage', source, {
        vehicles = owned
    })
end)

RegisterNetEvent('whellco_vehicles:closeGarage', function()
    local source = source

    TriggerClientEvent('whellco_vehicles:closeGarage', source)
end)

RegisterNetEvent('whellco_vehicles:spawnVehicle', function(vehicleId)
    local source = source
    local garage = Config.Garages.legion_garage

    if not garage then
        return
    end

    local characterId = GetPlayerIdentifierByType(source, 'license')

    if not characterId then
        return
    end

    local vehicle = MySQL.single.await(
        'SELECT id, model, plate FROM whellco_vehicles WHERE id = ? AND character_id = ? AND stored = 1 LIMIT 1',
        { vehicleId, characterId }
    )

    if not vehicle then
        return
    end

    local ped = GetPlayerPed(source)

    if #(GetEntityCoords(ped) - garage.coords) > 10.0 then
        return
    end

    local spawned = CreateVehicle(joaat(vehicle.model), garage.spawn.x, garage.spawn.y, garage.spawn.z, garage.spawn.w, true, false)

    if spawned == 0 then
        return
    end

    SetVehicleNumberPlateText(spawned, vehicle.plate)

    activeVehicles[vehicle.id] = spawned

    MySQL.update.await(
        'UPDATE whellco_vehicles SET stored = 0 WHERE id = ?',
        { vehicle.id }
    )

    TriggerClientEvent('whellco_vehicles:vehicleSpawned', source, {
        vehicle = vehicle.id
    })
end)

RegisterNetEvent('whellco_vehicles:storeVehicle', function()
    local source = source
    local characterId = GetPlayerIdentifierByType(source, 'license')

    if not characterId then
        return
    end

    local ped = GetPlayerPed(source)
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle == 0 then
        return
    end

    local plate = GetVehicleNumberPlateText(vehicle)

    local owned = MySQL.single.await(
        'SELECT id FROM whellco_vehicles WHERE character_id = ? AND plate = ? LIMIT 1',
        { characterId, plate }
    )

    if not owned then
        return
    end

    DeleteEntity(vehicle)

    activeVehicles[owned.id] = nil

    MySQL.update.await(
        'UPDATE whellco_vehicles SET stored = 1 WHERE id = ?',
        { owned.id }
    )

    TriggerClientEvent('whellco_vehicles:vehicleStored', source)
end)

RegisterNetEvent('whellco_vehicles:openDealership', function()
    local source = source
    local dealership = Config.Dealership

    if not dealership then
        return
    end

    local ped = GetPlayerPed(source)

    if #(GetEntityCoords(ped) - dealership.coords) > 10.0 then
        return
    end

    TriggerClientEvent('whellco_vehicles:openDealership', source, {
        vehicles = dealership.vehicles
    })
end)

RegisterNetEvent('whellco_vehicles:closeDealership', function()
    local source = source

    TriggerClientEvent('whellco_vehicles:closeDealership', source)
end)

RegisterNetEvent('whellco_vehicles:purchaseVehicle', function(model)
    local source = source
    local dealership = Config.Dealership

    if not dealership then
        return
    end

    local vehicle = nil

    for _, entry in ipairs(dealership.vehicles) do
        if entry.model == model then
            vehicle = entry
            break
        end
    end

    if not vehicle then
        return
    end

    local characterId = GetPlayerIdentifierByType(source, 'license')

    if not characterId then
        return
    end

    local account = MySQL.single.await(
        'SELECT cash FROM whellco_players WHERE character_id = ? LIMIT 1',
        { characterId }
    )

    if not account or (account.cash or 0) < vehicle.price then
        return
    end

    local plate = generatePlate()

    MySQL.transaction.await({
        {
            query = 'UPDATE whellco_players SET cash = cash - ? WHERE character_id = ? AND cash >= ?',
            values = { vehicle.price, characterId, vehicle.price }
        },
        {
            query = [[
                INSERT INTO whellco_vehicles
                    (character_id, model, plate, stored, garage)
                VALUES (?, ?, ?, 1, 'legion_garage')
            ]],
            values = { characterId, vehicle.model, plate }
        }
    })

    TriggerClientEvent('whellco_vehicles:notify', source, ('Purchased %s for %s%d.'):format(vehicle.label, '£', vehicle.price))
end)

AddEventHandler('playerDropped', function()
    local characterId = GetPlayerIdentifierByType(source, 'license')

    if characterId and activeVehicles[characterId] then
        activeVehicles[characterId] = nil
    end
end)
