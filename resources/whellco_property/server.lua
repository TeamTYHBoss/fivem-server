local QBCore = exports['qb-core']:GetCoreObject()

local function getProperty(propertyId)
    return MySQL.single.await(
        [[
            SELECT id, owner_citizenid, for_sale, price, locked
            FROM whellco_properties
            WHERE property_id = ?
        ]],
        { propertyId }
    )
end

local function createProperty(propertyId, propertyType)
    local config = Config.PropertyTypes[propertyType]

    MySQL.insert.await(
        [[
            INSERT INTO whellco_properties
                (property_id, property_type, price, for_sale)
            VALUES (?, ?, ?, 1)
        ]],
        { propertyId, propertyType, config.price }
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
            FROM whellco_property_keys
            WHERE property_id = ?
              AND citizenid = ?
        ]],
        { property.property_id, Player.PlayerData.citizenid }
    )

    return keys and keys > 0
end

RegisterNetEvent('whellco_property:enter', function(propertyId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local property = getProperty(propertyId)

    if not Player or not property then
        TriggerClientEvent('QBCore:Notify', source, 'Property not found.', 'error')
        return
    end

    if property.locked and not hasAccess(Player, property) then
        TriggerClientEvent('QBCore:Notify', source, 'This property is locked.', 'error')
        return
    end

    local config = Config.Properties[propertyId]

    TriggerClientEvent('whellco_property:enter', source, {
        propertyId = propertyId,
        label = config.label,
        coords = config.interior
    })
end)

RegisterNetEvent('whellco_property:exit', function(propertyId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local config = Config.Properties[propertyId]

    if not Player or not config then
        return
    end

    TriggerClientEvent('whellco_property:exit', source, {
        propertyId = propertyId,
        coords = config.entrance
    })
end)

RegisterNetEvent('whellco_property:purchase', function(propertyId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local property = getProperty(propertyId)
    local config = Config.Properties[propertyId]

    if not Player or not property or not config then
        return
    end

    if not property.for_sale then
        TriggerClientEvent('QBCore:Notify', source, 'This property is not for sale.', 'error')
        return
    end

    local price = property.price or config.price

    if Player.Functions.GetMoney('bank') < price then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough money in your bank account.', 'error')
        return
    end

    Player.Functions.RemoveMoney('bank', price, ('Property purchase: %s'):format(propertyId))

    MySQL.update.await(
        [[
            UPDATE whellco_properties
            SET owner_citizenid = ?, for_sale = 0, price = ?
            WHERE property_id = ?
        ]],
        { Player.PlayerData.citizenid, price, propertyId }
    )

    TriggerClientEvent('QBCore:Notify', source, ('Purchased %s for %s%d.'):format(config.label, Config.CurrencySymbol, price), 'success')
end)

RegisterNetEvent('whellco_property:toggleLock', function(propertyId)
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

    local newState = property.locked == 1 and 0 or 1

    MySQL.update.await(
        [[
            UPDATE whellco_properties
            SET locked = ?
            WHERE property_id = ?
        ]],
        { newState, propertyId }
    )

    TriggerClientEvent('QBCore:Notify', source, newState == 1 and 'Property locked.' or 'Property unlocked.', 'success')
end)

RegisterNetEvent('whellco_property:giveKey', function(propertyId, targetCitizenId)
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
            FROM whellco_property_keys
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
            INSERT INTO whellco_property_keys
                (property_id, citizenid)
            VALUES (?, ?)
            ON DUPLICATE KEY UPDATE property_id = VALUES(property_id)
        ]],
        { propertyId, targetCitizenId }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Property key granted.', 'success')
end)

RegisterCommand('properties', function(source)
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

RegisterCommand('buyproperty', function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    local propertyId = args[1]

    if not Player or not propertyId then
        return
    end

    TriggerEvent('whellco_property:purchase', propertyId)
end, false)