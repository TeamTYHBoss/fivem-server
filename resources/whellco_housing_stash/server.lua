local QBCore = exports['qb-core']:GetCoreObject()

local function getProperty(propertyId)
    return MySQL.single.await(
        [[
            SELECT id, owner_citizenid, locked
            FROM whellco_housing_properties
            WHERE property_id = ?
        ]],
        { propertyId }
    )
end

local function createProperty(propertyId, propertyType)
    MySQL.insert.await(
        [[
            INSERT INTO whellco_housing_properties
                (property_id, property_type, for_sale)
            VALUES (?, ?, 1)
        ]],
        { propertyId, propertyType }
    )
end

local function hasAccess(Player, property)
    if not property then
        return false
    end

    if property.owner_citizenid == Player.PlayerData.citizenid then
        return true
    end

    local keys = MySQL.scalar.await(
        [[
            SELECT COUNT(*)
            FROM whellco_housing_keys
            WHERE property_id = ?
              AND citizenid = ?
        ]],
        { property.property_id, Player.PlayerData.citizenid }
    )

    return keys and keys > 0
end

local function getStash(propertyId)
    local row = MySQL.single.await(
        [[
            SELECT items
            FROM whellco_housing_stash
            WHERE property_id = ?
        ]],
        { propertyId }
    )

    if row and row.items then
        local ok, items = pcall(json.decode, row.items)

        if ok and type(items) == 'table' then
            return items
        end
    end

    return {}
end

local function saveStash(propertyId, items)
    MySQL.query.await(
        [[
            INSERT INTO whellco_housing_stash
                (property_id, items)
            VALUES (?, ?)
            ON DUPLICATE KEY UPDATE
                items = VALUES(items)
        ]],
        { propertyId, json.encode(items) }
    )
end

RegisterNetEvent('whellco_housing_stash:enter', function(propertyId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local property = getProperty(propertyId)
    local config = Config.Properties[propertyId]

    if not Player or not property or not config then
        TriggerClientEvent('QBCore:Notify', source, 'Property not found.', 'error')
        return
    end

    if property.locked == 1 and not hasAccess(Player, property) then
        TriggerClientEvent('QBCore:Notify', source, 'This property is locked.', 'error')
        return
    end

    TriggerClientEvent('whellco_housing_stash:enter', source, {
        propertyId = propertyId,
        label = config.label,
        coords = config.exit
    })
end)

RegisterNetEvent('whellco_housing_stash:openStash', function(propertyId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local property = getProperty(propertyId)
    local config = Config.Properties[propertyId]

    if not Player or not property or not config then
        return
    end

    if not hasAccess(Player, property) then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have access to this stash.', 'error')
        return
    end

    local housingType = Config.HousingTypes[config.type]

    TriggerClientEvent('whellco_housing_stash:openStash', source, {
        propertyId = propertyId,
        label = config.label,
        slots = housingType.stashSlots,
        weight = housingType.stashWeight,
        items = getStash(propertyId)
    })
end)

RegisterNetEvent('whellco_housing_stash:saveStash', function(propertyId, items)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local property = getProperty(propertyId)

    if not Player or not property or not hasAccess(Player, property) then
        return
    end

    if type(items) ~= 'table' then
        return
    end

    saveStash(propertyId, items)

    TriggerClientEvent('QBCore:Notify', source, 'Stash saved.', 'success')
end)

RegisterNetEvent('whellco_housing_stash:purchase', function(propertyId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local property = getProperty(propertyId)
    local config = Config.Properties[propertyId]

    if not Player or not property or not config then
        return
    end

    if property.owner_citizenid then
        TriggerClientEvent('QBCore:Notify', source, 'This property is already owned.', 'error')
        return
    end

    local housingType = Config.HousingTypes[config.type]

    if Player.Functions.GetMoney('bank') < housingType.price then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough money in your bank account.', 'error')
        return
    end

    Player.Functions.RemoveMoney('bank', housingType.price, ('Property purchase: %s'):format(propertyId))

    MySQL.update.await(
        [[
            UPDATE whellco_housing_properties
            SET owner_citizenid = ?, for_sale = 0
            WHERE property_id = ?
        ]],
        { Player.PlayerData.citizenid, propertyId }
    )

    TriggerClientEvent('QBCore:Notify', source, ('Purchased %s for %s%d.'):format(config.label, Config.CurrencySymbol, housingType.price), 'success')
end)

RegisterNetEvent('whellco_housing_stash:giveKey', function(propertyId, targetCitizenId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local property = getProperty(propertyId)

    if not Player or not property then
        return
    end

    if property.owner_citizenid ~= Player.PlayerData.citizenid then
        TriggerClientEvent('QBCore:Notify', source, 'You do not own this property.', 'error')
        return
    end

    local keyCount = MySQL.scalar.await(
        [[
            SELECT COUNT(*)
            FROM whellco_housing_keys
            WHERE property_id = ?
        ]],
        { propertyId }
    )

    if keyCount >= Config.MaxKeysPerProperty then
        TriggerClientEvent('QBCore:Notify', source, 'Key limit reached.', 'error')
        return
    end

    MySQL.query.await(
        [[
            INSERT INTO whellco_housing_keys
                (property_id, citizenid)
            VALUES (?, ?)
            ON DUPLICATE KEY UPDATE property_id = VALUES(property_id)
        ]],
        { propertyId, targetCitizenId }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Property key granted.', 'success')
end)

RegisterCommand('housing', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local names = {}

    for id, property in pairs(Config.Properties) do
        names[#names + 1] = ('%s - %s'):format(id, property.label)
    end

    TriggerClientEvent('QBCore:Notify', source, table.concat(names, ', '), 'primary')
end, false)

RegisterCommand('buynhouse', function(source, args)
    local propertyId = args[1]

    if not propertyId then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /buynhouse [property_id]', 'error')
        return
    end

    TriggerEvent('whellco_housing_stash:purchase', propertyId)
end, false)