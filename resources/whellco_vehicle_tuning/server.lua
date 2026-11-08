local QBCore = exports['qb-core']:GetCoreObject()

local saveCooldowns = {}

local function isNear(coords, shop)
    return #(coords - shop.location) <= shop.radius
end

local function getMods(plate)
    local row = MySQL.single.await(
        [[
            SELECT mods
            FROM whellco_vehicle_tuning
            WHERE plate = ?
        ]],
        { plate }
    )

    if row and row.mods then
        local ok, mods = pcall(json.decode, row.mods)

        if ok and type(mods) == 'table' then
            return mods
        end
    end

    return {}
end

local function saveMods(plate, mods)
    MySQL.query.await(
        [[
            INSERT INTO whellco_vehicle_tuning
                (plate, mods)
            VALUES (?, ?)
            ON DUPLICATE KEY UPDATE
                mods = VALUES(mods)
        ]],
        { plate, json.encode(mods) }
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

RegisterNetEvent('whellco_vehicle_tuning:applyMod', function(shopId, modType, level)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local shop = Config.TuningShops[shopId]
    local mod = Config.Mods[modType]

    if not Player or not shop or not mod then
        return
    end

    level = math.floor(tonumber(level) or 0)

    if level < 0 or level > mod.maxLevel then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid mod level.', 'error')
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if not isNear(coords, shop) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not near a tuning shop.', 'error')
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

    local cost = mod.pricePerLevel * level

    if Player.Functions.GetMoney('cash') < cost then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough cash.', 'error')
        return
    end

    Player.Functions.RemoveMoney('cash', cost, ('Vehicle tuning: %s'):format(modType))

    local mods = getMods(plate)
    mods[modType] = level

    saveMods(plate, mods)

    TriggerClientEvent('whellco_vehicle_tuning:applyMod', source, {
        modType = modType,
        level = level
    })

    TriggerClientEvent('QBCore:Notify', source, ('Applied %s level %d for %s%d.'):format(mod.label, level, Config.CurrencySymbol, cost), 'success')
end)

RegisterNetEvent('whellco_vehicle_tuning:applyColor', function(shopId, colorType, r, g, b)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local shop = Config.TuningShops[shopId]
    local color = Config.Colors[colorType]

    if not Player or not shop or not color then
        return
    end

    r = math.floor(tonumber(r) or 0)
    g = math.floor(tonumber(g) or 0)
    b = math.floor(tonumber(b) or 0)

    if r < 0 or r > 255 or g < 0 or g > 255 or b < 0 or b > 255 then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid colour values.', 'error')
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if not isNear(coords, shop) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not near a tuning shop.', 'error')
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

    if Player.Functions.GetMoney('cash') < color.price then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough cash.', 'error')
        return
    end

    Player.Functions.RemoveMoney('cash', color.price, ('Vehicle colour: %s'):format(colorType))

    local mods = getMods(plate)
    mods[colorType] = { r = r, g = g, b = b }

    saveMods(plate, mods)

    TriggerClientEvent('whellco_vehicle_tuning:applyColor', source, {
        colorType = colorType,
        r = r,
        g = g,
        b = b
    })

    TriggerClientEvent('QBCore:Notify', source, ('Applied %s for %s%d.'):format(color.label, Config.CurrencySymbol, color.price), 'success')
end)

RegisterNetEvent('whellco_vehicle_tuning:saveVehicle', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local playerPed = GetPlayerPed(source)
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if not Player or vehicle == 0 then
        return
    end

    local plate = QBCore.Shared.Trim(GetVehicleNumberPlateText(vehicle))

    if not ownsVehicle(Player, plate) then
        return
    end

    local now = os.time()

    if now - (saveCooldowns[source] or 0) < Config.SaveCooldownSeconds then
        return
    end

    local props = QBCore.Functions.GetVehicleProperties(vehicle)

    MySQL.update.await(
        [[
            UPDATE player_vehicles
            SET mods = ?
            WHERE citizenid = ?
              AND plate = ?
        ]],
        {
            json.encode(props),
            Player.PlayerData.citizenid,
            plate
        }
    )

    saveCooldowns[source] = now

    TriggerClientEvent('QBCore:Notify', source, 'Vehicle saved.', 'success')
end)

RegisterCommand('tunemods', function(source, args)
    local shopId = args[1]
    local modType = args[2]
    local level = tonumber(args[3])

    if not shopId or not modType or not level then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /tunemods [shop] [mod] [level]', 'error')
        return
    end

    TriggerEvent('whellco_vehicle_tuning:applyMod', shopId, modType, level)
end, false)

RegisterCommand('tunecolor', function(source, args)
    local shopId = args[1]
    local colorType = args[2]
    local r = tonumber(args[3])
    local g = tonumber(args[4])
    local b = tonumber(args[5])

    if not shopId or not colorType or not r or not g or not b then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /tunecolor [shop] [primary|secondary] [r] [g] [b]', 'error')
        return
    end

    TriggerEvent('whellco_vehicle_tuning:applyColor', shopId, colorType, r, g, b)
end, false)

RegisterCommand('savevehicle', function()
    TriggerEvent('whellco_vehicle_tuning:saveVehicle')
end, false)