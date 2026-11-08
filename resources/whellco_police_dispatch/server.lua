local QBCore = exports['qb-core']:GetCoreObject()

local cooldowns = {}
local activeCalls = {}
local nextCallId = 1

local function isPolice(Player)
    local job = Player.PlayerData.job

    return job and Config.PoliceJobs[job.name]
end

local function getPolicePlayers()
    local players = QBCore.Functions.GetQBCorePlayers()
    local police = {}

    for _, Player in pairs(players) do
        if isPolice(Player) then
            police[#police + 1] = Player.PlayerData.source
        end
    end

    return police
end

RegisterNetEvent('whellco_police_dispatch:sendCall', function(callType, details)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local call = Config.CallTypes[callType]

    if not Player or not call then
        return
    end

    local now = os.time()

    if now - (cooldowns[source] or 0) < Config.CooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before sending another police dispatch call.', 'error')
        return
    end

    cooldowns[source] = now
    details = tostring(details or ''):sub(1, 180)

    local callId = nextCallId
    nextCallId = nextCallId + 1

    local dispatch = {
        id = callId,
        type = callType,
        label = call.label,
        priority = call.priority,
        details = details,
        coords = GetEntityCoords(GetPlayerPed(source)),
        sender = Player.PlayerData.citizenid,
        senderName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        createdAt = now
    }

    activeCalls[callId] = dispatch

    local recipients = getPolicePlayers()

    for _, recipient in ipairs(recipients) do
        TriggerClientEvent('whellco_police_dispatch:receiveCall', recipient, dispatch, {
            blipSprite = call.blipSprite,
            blipColor = call.blipColor,
            sound = call.sound,
            soundSet = call.soundSet,
            duration = Config.NotificationDuration
        })
    end

    TriggerClientEvent('QBCore:Notify', source, ('Police dispatch sent: %s.'):format(call.label), 'success')
end)

RegisterNetEvent('whellco_police_dispatch:requestRoute', function(callId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local call = activeCalls[callId]

    if not Player or not call or not isPolice(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have access to this dispatch route.', 'error')
        return
    end

    TriggerClientEvent('whellco_police_dispatch:setRoute', source, callId)
end)

RegisterNetEvent('whellco_police_dispatch:clearCall', function(callId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local call = activeCalls[callId]

    if not Player or not call or not isPolice(Player) then
        return
    end

    activeCalls[callId] = nil

    TriggerClientEvent('whellco_police_dispatch:clearCall', -1, callId)
    TriggerClientEvent('QBCore:Notify', source, 'Police dispatch call cleared.', 'success')
end)

AddEventHandler('playerDropped', function()
    cooldowns[source] = nil
end)

CreateThread(function()
    while true do
        Wait(30000)

        local now = os.time()

        for callId, call in pairs(activeCalls) do
            if now - call.createdAt > Config.RouteTimeoutSeconds then
                activeCalls[callId] = nil
                TriggerClientEvent('whellco_police_dispatch:clearCall', -1, callId)
            end
        end
    end
end)