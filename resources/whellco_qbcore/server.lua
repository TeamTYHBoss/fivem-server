local QBCore = exports['qb-core']:GetCoreObject()

--- Returns the QBCore player object for a source.
local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

exports('getQbPlayer', getQbPlayer)

--- Returns the player's citizenid.
local function getCitizenId(source)
    local Player = getQbPlayer(source)

    return Player and Player.PlayerData.citizenid or nil
end

exports('getCitizenId', getCitizenId)

--- Returns the player's license identifier.
local function getIdentifier(source)
    local Player = getQbPlayer(source)

    return Player and Player.PlayerData.identifier or nil
end

exports('getIdentifier', getIdentifier)

--- Returns a money balance from the QBCore player.
local function getMoney(source, account)
    local Player = getQbPlayer(source)

    if not Player then
        return 0
    end

    return Player.Functions.GetMoney(account or 'cash') or 0
end

exports('getMoney', getMoney)

--- Removes money from a QBCore player.
local function removeMoney(source, amount, reason, account)
    local Player = getQbPlayer(source)

    if not Player then
        return false
    end

    amount = math.floor(tonumber(amount) or 0)

    if amount <= 0 then
        return false
    end

    return Player.Functions.RemoveMoney(account or 'cash', amount, reason or 'WhellCo transaction')
end

exports('removeMoney', removeMoney)

--- Adds money to a QBCore player.
local function addMoney(source, amount, reason, account)
    local Player = getQbPlayer(source)

    if not Player then
        return false
    end

    amount = math.floor(tonumber(amount) or 0)

    if amount <= 0 then
        return false
    end

    return Player.Functions.AddMoney(account or 'cash', amount, reason or 'WhellCo transaction')
end

exports('addMoney', addMoney)

--- Sends a QBCore notification.
local function notify(source, message, notificationType)
    TriggerClientEvent('QBCore:Notify', source, message or '', notificationType or 'primary')
end

exports('notify', notify)
