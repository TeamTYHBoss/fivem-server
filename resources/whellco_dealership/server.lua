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

local function getOwnedVehicles(identifier)
    return MySQL.query.await(
        [[
            SELECT id, model, plate, primary_color, secondary_color, pearl_color, wheel_color,
                   engine_level, brakes_level, transmission_level, armor_level, turbo, stored
            FROM whellco_vehicles
            WHERE owner_id = ?
            ORDER BY created_at DESC
        ]],
        { identifier }
    ) or {}
end

local function sendDealership(source)
    local vehicles = {}

    for id, vehicle in pairs(Config.Vehicles) do
        vehicles[#vehicles + 1] = {
            id = id,
            label = vehicle.label,
            model = vehicle.model,
            price = vehicle.price,
            category = vehicle.category
        }
    end

    TriggerClientEvent('whellco_dealership:openDealership', source, {
        vehicles = vehicles
    })
end

local function sendGarage(source)
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local customization = {}

    for id, option in pairs(Config.Customization) do
        customization[#customization + 1] = {
            id = id,
            label = option.label,
            price = option.price
        }
    end

    TriggerClientEvent('whellco_dealership:openGarage', source, {
        vehicles = getOwnedVehicles(identifier),
        customization = customization
    })
end

RegisterNetEvent('whellco_dealership:openDealership', function()
    sendDealership(source)
end)

RegisterNetEvent('whellco_dealership:openGarage', function()
    sendGarage(source)
end)

RegisterNetEvent('whellco_dealership:closeMenu', function()
    TriggerClientEvent('whellco_dealership:closeMenu', source)
end)

RegisterNetEvent('whellco_dealership:buyVehicle', function(vehicleId)
    local source = source
    local vehicle = Config.Vehicles[vehicleId]

    if not vehicle then
        return
    end

    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local plate = generatePlate()

    MySQL.insert.await(
        [[
            INSERT INTO whellco_vehicles
                (owner_id, model, plate)
            VALUES (?, ?, ?)
        ]],
        { identifier, vehicle.model, plate }
    )

    TriggerClientEvent('whellco_dealership:notify', source, ('Purchased %s for £%s. Plate: %s'):format(vehicle.label, vehicle.price, plate))
    TriggerClientEvent('whellco_dealership:spawnVehicle', source, {
        model = vehicle.model,
        plate = plate,
        coords = Config.Dealership.spawn,
        heading = Config.Dealership.heading,
        primaryColor = 0,
        secondaryColor = 0,
        pearlColor = 0,
        wheelColor = 0
    })
end)

RegisterNetEvent('whellco_dealership:retrieveVehicle', function(vehicleId)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local vehicle = MySQL.single.await(
        [[
            SELECT id, model, plate, primary_color, secondary_color, pearl_color, wheel_color,
                   engine_level, brakes_level, transmission_level, armor_level, turbo
            FROM whellco_vehicles
            WHERE id = ? AND owner_id = ?
            LIMIT 1
        ]],
        { vehicleId, identifier }
    )

    if not vehicle then
        return
    end

    MySQL.query.await(
        [[
            UPDATE whellco_vehicles
            SET stored = 0
            WHERE id = ?
        ]],
        { vehicleId }
    )

    TriggerClientEvent('whellco_dealership:spawnVehicle', source, {
        model = vehicle.model,
        plate = vehicle.plate,
        coords = Config.Garage.spawn,
        heading = Config.Garage.heading,
        primaryColor = vehicle.primary_color,
        secondaryColor = vehicle.secondary_color,
        pearlColor = vehicle.pearl_color,
        wheelColor = vehicle.wheel_color,
        engineLevel = vehicle.engine_level,
        brakesLevel = vehicle.brakes_level,
        transmissionLevel = vehicle.transmission_level,
        armorLevel = vehicle.armor_level,
        turbo = vehicle.turbo == 1
    })
end)

RegisterNetEvent('whellco_dealership:storeVehicle', function(vehicleId)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    MySQL.query.await(
        [[
            UPDATE whellco_vehicles
            SET stored = 1
            WHERE id = ? AND owner_id = ?
        ]],
        { vehicleId, identifier }
    )

    TriggerClientEvent('whellco_dealership:notify', source, 'Vehicle stored.')
    sendGarage(source)
end)

RegisterNetEvent('whellco_dealership:customizeVehicle', function(vehicleId, customizationType, value)
    local source = source
    local identifier = getIdentifier(source)
    local option = Config.Customization[customizationType]

    if not option then
        return
    end

    if not identifier then
        return
    end

    local vehicle = MySQL.single.await(
        [[
            SELECT id
            FROM whellco_vehicles
            WHERE id = ? AND owner_id = ?
            LIMIT 1
        ]],
        { vehicleId, identifier }
    )

    if not vehicle then
        return
    end

    local column = {
        primaryColor = 'primary_color',
        secondaryColor = 'secondary_color',
        pearlColor = 'pearl_color',
        wheelColor = 'wheel_color',
        engine = 'engine_level',
        brakes = 'brakes_level',
        transmission = 'transmission_level',
        armor = 'armor_level',
        turbo = 'turbo'
    }[customizationType]

    if not column then
        return
    end

    local safeValue = tonumber(value) or 0

    if customizationType == 'turbo' then
        safeValue = safeValue > 0 and 1 or 0
    end

    MySQL.transaction.await({
        {
            query = ('UPDATE whellco_vehicles SET %s = ? WHERE id = ?'):format(column),
            values = { safeValue, vehicleId }
        },
        {
            query = [[
                INSERT INTO whellco_vehicle_customization_history
                    (vehicle_id, customization_type, price)
                VALUES (?, ?, ?)
            ]],
            values = { vehicleId, customizationType, option.price }
        }
    })

    TriggerClientEvent('whellco_dealership:notify', source, ('%s applied for £%s.'):format(option.label, option.price))
    sendGarage(source)
end)
