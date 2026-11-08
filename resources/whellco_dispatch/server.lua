local QBCore = exports['qb-core']:GetCoreObject()

local cooldowns = {}
local activeCalls = {}
local nextCallId = 1

local function getEligiblePlayers(callType)
    local call = Config.CallTypes[callType]
    local eligible = {}

    if not call then
        return eligible
    end

    local players = QBCore.Functions.GetQBCorePlayers()

    for _, Player in pairs(players) do
        local job = Player.PlayerData.job

        if job and call.jobs[job.name] then
            eligible[#eligible + 1] = Player.PlayerData.source
        end
    end

    return eligible
end

RegisterNetEvent('whellco_dispatch:sendCall', function(callType, details)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local call = Config.CallTypes[callType]

    if not Player or not call then
        return
    end

    local now = os.time()

    if now - (cooldowns[source] or 0) < Config.CooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before sending another dispatch call.', 'error')
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

    local recipients = getEligiblePlayers(callType)

    for _, recipient in ipairs(recipients) do
        TriggerClientEvent('whellco_dispatch:receiveCall', recipient, dispatch, {
            job = Config.DispatchJobs[call.jobs[1]],
            blipSprite = call.blipSprite,
            blipColor = call.blipColor,
            duration = Config.NotificationDuration
        })
    end

    TriggerClientEvent('QBCore:Notify', source, ('Dispatch call sent: %s.'):format(call.label), 'success')

    if Config.Debug then
        print(('[whellco_dispatch] Call %d sent to %d eligible player(s).'):format(callId, #recipients))
    end
end)

RegisterNetEvent('whellco_dispatch:clearCall', function(callId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local call = activeCalls[callId]

    if not Player or not call then
        return
    end

    local job = Player.PlayerData.job

    if not job or not call or not Config.CallTypes[call.type].jobs[job.name] then
        return
    end

    activeCalls[callId] = nil

    TriggerClientEvent('whellco_dispatch:clearCall', -1, callId)
    TriggerClientEvent('QBCore:Notify', source, 'Dispatch call cleared.', 'success')
end)

AddEventHandler('playerDropped', function()
    cooldowns[source] = nil
end)

CreateThread(function()
    while true do
        Wait(30000)

        local now = os.time()

        for callId, call in pairs(activeCalls) do
            if now - call.createdAt > Config.BlipLifetimeSeconds then
                activeCalls[callId] = nil
                TriggerClientEvent('whellco_dispatch:clearCall', -1, callId)
            end
        end
    end
end)