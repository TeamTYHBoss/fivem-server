local QBCore = exports['qb-core']:GetCoreObject()

local checkCooldowns = {}

local function isSecurity(Player)
    local job = Player.PlayerData.job

    return job and job.name == Config.SecurityJob
end

local function isNear(coords, door)
    return #(coords - door.location) <= door.radius
end

RegisterNetEvent('whellco_bouncer_id_check:check', function(targetSource)
    local source = source
    local Guard = QBCore.Functions.GetPlayer(source)
    local Target = QBCore.Functions.GetPlayer(tonumber(targetSource) or 0)

    if not Guard or not Target or not isSecurity(Guard) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not authorised to check IDs.', 'error')
        return
    end

    local now = os.time()

    if now - (checkCooldowns[source] or 0) < Config.CheckCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before checking another ID.', 'error')
        return
    end

    local guardPed = GetPlayerPed(source)
    local coords = GetEntityCoords(guardPed)

    if not isNear(coords, Config.FrontDoor) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not at the front door.', 'error')
        return
    end

    checkCooldowns[source] = now

    local validId = Target.Functions.GetItemByName(Config.ValidIdItem)
    local fakeId = Target.Functions.GetItemByName(Config.FakeIdItem)

    local result = {
        targetSource = Target.PlayerData.source,
        targetName = Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname,
        hasValidId = validId ~= nil,
        hasFakeId = fakeId ~= nil,
        allowed = validId ~= nil and fakeId == nil
    }

    TriggerClientEvent('whellco_bouncer_id_check:result', source, result)
    TriggerClientEvent('whellco_bouncer_id_check:checked', Target.PlayerData.source, result)
end)

RegisterCommand('checkid', function(source, args)
    local targetSource = args[1]

    if not targetSource then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /checkid [player_id]', 'error')
        return
    end

    TriggerEvent('whellco_bouncer_id_check:check', targetSource)
end, false)