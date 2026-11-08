local QBCore = exports['qb-core']:GetCoreObject()

--- Returns the QBCore citizen ID for a source.
local function getCitizenId(source)
    local Player = QBCore.Functions.GetPlayer(source)

    return Player and Player.PlayerData.citizenid or nil
end

--- Returns a vehicle owner identifier, using QBCore citizen ID.
local function getVehicleOwner(source)
    return getCitizenId(source)
end

--- Checks whether a player owns a vehicle record.
local function ownsVehicle(source, ownerColumn, tableName, vehicleId)
    local citizenId = getCitizenId(source)

    if not citizenId then
        return false
    end

    return MySQL.scalar.await(
        ('SELECT COUNT(*) FROM %s WHERE id = ? AND %s = ?'):format(tableName, ownerColumn),
        { vehicleId, citizenId }
    ) > 0
end

exports('getCitizenId', getCitizenId)
exports('getVehicleOwner', getVehicleOwner)
exports('ownsVehicle', ownsVehicle)