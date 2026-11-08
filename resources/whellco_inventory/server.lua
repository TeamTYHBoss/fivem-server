local QBCore = exports['qb-core']:GetCoreObject()

local activeStorages = {}

local function getStorageKey(storageType, identifier)
    return ('%s:%s'):format(storageType, identifier)
end

local function getStorage(storageType, identifier)
    local key = getStorageKey(storageType, identifier)

    if activeStorages[key] then
        return activeStorages[key]
    end

    local row = MySQL.single.await(
        [[
            SELECT items
            FROM whellco_inventory_storages
            WHERE storage_type = ?
              AND identifier = ?
        ]],
        { storageType, identifier }
    )

    local items = {}

    if row and row.items then
        local ok, decoded = pcall(json.decode, row.items)

        if ok and type(decoded) == 'table' then
            items = decoded
        end
    end

    local storage = {
        type = storageType,
        identifier = identifier,
        items = items
    }

    activeStorages[key] = storage

    return storage
end

local function saveStorage(storage)
    MySQL.query.await(
        [[
            INSERT INTO whellco_inventory_storages
                (storage_type, identifier, items)
            VALUES (?, ?, ?)
            ON DUPLICATE KEY UPDATE
                items = VALUES(items)
        ]],
        { storage.type, storage.identifier, json.encode(storage.items) }
    )
end

local function getItemCount(storage, itemName)
    return storage.items[itemName] or 0
end

local function addItem(storage, itemName, amount)
    local item = Config.AllowedItems[itemName]

    if not item or not item.stackable then
        return false, 'Item cannot be stacked.'
    end

    amount = math.floor(tonumber(amount) or 0)

    if amount <= 0 then
        return false, 'Invalid item amount.'
    end

    local current = getItemCount(storage, itemName)
    local newAmount = current + amount

    if newAmount > Config.MaxItemStack then
        return false, 'Item stack limit reached.'
    end

    storage.items[itemName] = newAmount

    return true
end

local function removeItem(storage, itemName, amount)
    amount = math.floor(tonumber(amount) or 0)

    if amount <= 0 then
        return false, 'Invalid item amount.'
    end

    local current = getItemCount(storage, itemName)

    if current < amount then
        return false, 'Not enough items.'
    end

    local newAmount = current - amount

    if newAmount == 0 then
        storage.items[itemName] = nil
    else
        storage.items[itemName] = newAmount
    end

    return true
end

RegisterNetEvent('whellco_inventory:openStorage', function(storageType, identifier)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local storageConfig = Config.StorageTypes[storageType]

    if not Player or not storageConfig then
        return
    end

    if storageConfig.requiresOwnership then
        local owned = false

        if storageType == 'trunk' or storageType == 'glovebox' then
            owned = exports['whellco_qbcore']:ownsVehicle(source, 'citizenid', 'player_vehicles', identifier)
        elseif storageType == 'house' then
            owned = exports['whellco_housing']:ownsProperty(source, identifier)
        end

        if not owned then
            TriggerClientEvent('QBCore:Notify', source, 'You do not have access to this storage.', 'error')
            return
        end
    end

    local storage = getStorage(storageType, identifier)

    TriggerClientEvent('whellco_inventory:openStorage', source, {
        type = storageType,
        identifier = identifier,
        label = storageConfig.label,
        slots = storageConfig.slots,
        weight = storageConfig.weight,
        items = storage.items
    })
end)

RegisterNetEvent('whellco_inventory:moveItem', function(storageType, identifier, itemName, amount, direction)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local storageConfig = Config.StorageTypes[storageType]

    if not Player or not storageConfig then
        return
    end

    local storage = getStorage(storageType, identifier)
    local success, error

    if direction == 'deposit' then
        success, error = addItem(storage, itemName, amount)
    elseif direction == 'withdraw' then
        success, error = removeItem(storage, itemName, amount)
    end

    if not success then
        TriggerClientEvent('QBCore:Notify', source, error or 'Unable to move item.', 'error')
        return
    end

    saveStorage(storage)

    TriggerClientEvent('whellco_inventory:openStorage', source, {
        type = storageType,
        identifier = identifier,
        label = storageConfig.label,
        slots = storageConfig.slots,
        weight = storageConfig.weight,
        items = storage.items
    })

    TriggerClientEvent('QBCore:Notify', source, 'Item moved.', 'success')
end)

RegisterCommand('storage', function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local storageType = args[1]
    local identifier = args[2]

    if not storageType or not identifier then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /storage [type] [identifier]', 'error')
        return
    end

    TriggerEvent('whellco_inventory:openStorage', storageType, identifier)
end, false)