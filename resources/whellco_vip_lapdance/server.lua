local QBCore = exports['qb-core']:GetCoreObject()

local roomCooldowns = {}

local function isNear(coords, room)
    return #(coords - room.location) <= room.radius
end

RegisterNetEvent('whellco_vip_lapdance:start', function(roomId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local room = Config.VipRooms[roomId]

    if not Player or not room then
        TriggerClientEvent('QBCore:Notify', source, 'VIP room not found.', 'error')
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if not isNear(coords, room) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not near the VIP room.', 'error')
        return
    end

    local now = os.time()

    if now - (roomCooldowns[source] or 0) < Config.RoomCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before booking another VIP room.', 'error')
        return
    end

    if Player.Functions.GetMoney('cash') < room.price then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough cash.', 'error')
        return
    end

    Player.Functions.RemoveMoney('cash', room.price, ('VIP lap dance: %s'):format(roomId))

    roomCooldowns[source] = now

    TriggerClientEvent('whellco_vip_lapdance:start', source, {
        roomId = roomId,
        label = room.label,
        duration = Config.DanceDuration,
        animations = room.animations
    })
end)

RegisterCommand('bookvip', function(source, args)
    local roomId = args[1]

    if not roomId then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /bookvip [vip_1|vip_2]', 'error')
        return
    end

    TriggerEvent('whellco_vip_lapdance:start', roomId)
end, false)