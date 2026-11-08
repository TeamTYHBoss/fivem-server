local QBCore = exports['qb-core']:GetCoreObject()

local intoxication = {}
local recoveryCooldowns = {}

local function isNear(coords, club)
    return #(coords - club.location) <= club.radius
end

RegisterNetEvent('whellco_hangover_recovery:recover', function(itemName)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local now = os.time()

    if now - (recoveryCooldowns[source] or 0) < Config.RecoveryCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before recovering again.', 'error')
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if not isNear(coords, Config.StripClub) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not near the club.', 'error')
        return
    end

    local recoveryAmount = Config.RecoveryItems[itemName]

    if not recoveryAmount then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid recovery item selected.', 'error')
        return
    end

    local citizenid = Player.PlayerData.citizenid
    local currentIntoxication = intoxication[citizenid] or 0

    if currentIntoxication < Config.HangoverThreshold then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have a hangover.', 'error')
        return
    end

    if not Player.Functions.RemoveItem(itemName, 1) then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have that recovery item.', 'error')
        return
    end

    intoxication[citizenid] = math.max(0, currentIntoxication - recoveryAmount)
    recoveryCooldowns[source] = now

    TriggerClientEvent('whellco_hangover_recovery:recovered', source, {
        item = itemName,
        intoxication = intoxication[citizenid]
    })
end)

RegisterCommand('recover', function(source, args)
    local itemName = args[1]

    if not itemName then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /recover [item_name]', 'error')
        return
    end

    TriggerEvent('whellco_hangover_recovery:recover', itemName)
end, false)