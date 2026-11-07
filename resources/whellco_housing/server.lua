local resource = GetCurrentResourceName()
local dataFile = 'data/ownership.json'

local properties = {
    ['vinewood_apartment'] = {
        label = 'Vinewood Apartment',
        area = 'Los Santos',
        entrance = vector3(-269.4, -955.3, 31.2),
        price = 250000,
        interior = vector3(-267.3, -958.2, 31.2),
        interiorHeading = 250.0
    },
    ['legion_flat'] = {
        label = 'Legion Square Flat',
        area = 'Los Santos',
        entrance = vector3(230.1, -810.5, 30.6),
        price = 180000,
        interior = vector3(229.7, -813.4, 30.6),
        interiorHeading = 340.0
    },
    ['paleto_cottage'] = {
        label = 'Paleto Cottage',
        area = 'Blaine County',
        entrance = vector3(1391.9, 3607.4, 38.9),
        price = 75000,
        interior = vector3(1394.2, 3604.8, 38.9),
        interiorHeading = 180.0
    },
    ['sandy_house'] = {
        label = 'Sandy Shores House',
        area = 'Blaine County',
        entrance = vector3(1170.8, 2645.3, 38.1),
        price = 60000,
        interior = vector3(1173.1, 2642.7, 38.1),
        interiorHeading = 190.0
    }
}

local ownership = {}

local function loadData()
    local file = LoadResourceFile(resource, dataFile)

    if file and file ~= '' then
        local decoded = json.decode(file)

        if type(decoded) == 'table' then
            ownership = decoded
        end
    end
end

local function saveData()
    SaveResourceFile(resource, dataFile, json.encode(ownership), -1)
end

local function getNearbyProperty(player)
    local ped = GetPlayerPed(player)
    local coords = GetEntityCoords(ped)

    for id, property in pairs(properties) do
        local distance = #(coords - property.entrance)

        if distance <= 3.0 then
            return id, property, distance
        end
    end

    return nil
end

local function getPropertyForPlayer(player)
    for id, owner in pairs(ownership) do
        if owner == player then
            return id, properties[id]
        end
    end

    return nil
end

CreateThread(function()
    loadData()
end)

RegisterNetEvent('whellco_housing:requestProperties', function()
    local source = source
    local nearbyId, nearbyProperty = getNearbyProperty(source)
    local ownedId = getPropertyForPlayer(source)

    local list = {}

    for id, property in pairs(properties) do
        list[#list + 1] = {
            id = id,
            label = property.label,
            area = property.area,
            price = property.price,
            owned = ownership[id] ~= nil,
            ownedByYou = ownedId == id,
            nearby = nearbyId == id
        }
    end

    TriggerClientEvent('whellco_housing:receiveProperties', source, {
        properties = list,
        nearbyId = nearbyId,
        nearbyLabel = nearbyProperty and nearbyProperty.label or nil,
        ownedId = ownedId
    })
end)

RegisterNetEvent('whellco_housing:purchase', function(propertyId)
    local source = source

    if type(propertyId) ~= 'string' then
        return
    end

    local property = properties[propertyId]

    if not property then
        TriggerClientEvent('whellco_housing:notify', source, 'That property does not exist.')
        return
    end

    if ownership[propertyId] then
        TriggerClientEvent('whellco_housing:notify', source, 'That property has already been purchased.')
        return
    end

    if getPropertyForPlayer(source) then
        TriggerClientEvent('whellco_housing:notify', source, 'You already own a property.')
        return
    end

    local nearbyId = getNearbyProperty(source)

    if nearbyId ~= propertyId then
        TriggerClientEvent('whellco_housing:notify', source, 'You are not close enough to this property.')
        return
    end

    -- Replace this with your economy framework's server-side money check/removal.
    local hasEnoughMoney = true

    if not hasEnoughMoney then
        TriggerClientEvent('whellco_housing:notify', source, 'You cannot afford this property.')
        return
    end

    ownership[propertyId] = source
    saveData()

    TriggerClientEvent('whellco_housing:notify', source, ('You purchased %s for £%s.'):format(property.label, property.price))
    TriggerClientEvent('whellco_housing:receiveProperties', source, {
        properties = {},
        nearbyId = propertyId,
        nearbyLabel = property.label,
        ownedId = propertyId
    })
end)

RegisterNetEvent('whellco_housing:enter', function()
    local source = source
    local propertyId, property = getPropertyForPlayer(source)

    if not propertyId then
        TriggerClientEvent('whellco_housing:notify', source, 'You do not own a property.')
        return
    end

    local nearbyId = getNearbyProperty(source)

    if nearbyId ~= propertyId then
        TriggerClientEvent('whellco_housing:notify', source, 'You are not at your property entrance.')
        return
    end

    TriggerClientEvent('whellco_housing:teleport', source, property.interior, property.interiorHeading)
end)

AddEventHandler('playerDropped', function()
    local source = source

    for propertyId, owner in pairs(ownership) do
        if owner == source then
            ownership[propertyId] = nil
        end
    end

    saveData()
end)
