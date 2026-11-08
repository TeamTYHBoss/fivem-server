local QBCore = exports['qb-core']:GetCoreObject()

local scanCooldowns = {}

local function isSecurity(Player)
    local job = Player.PlayerData.job

    return job and job.name == Config.SecurityJob
end

local function isNear(coords, entrance)
    return #(coords - entrance.location) <= entrance.radius
end

RegisterNetEvent('whellco_id_scanner:scan', function(targetSource)
    local source = source
    local Guard = QBCore.Functions.GetPlayer(source)
    local Target = QBCore.Functions.GetPlayer(tonumber(targetSource) or 0)

    if not Guard or not Target or not isSecurity(Guard) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not authorised to scan IDs.', 'error')
        return
    end

    local now = os.time()

    if now - (scanCooldowns[source] or 0) < Config.ScanCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before scanning another ID.', 'error')
        return
    end

    local guardPed = GetPlayerPed(source)
    local coords = GetEntityCoords(guardPed)

    if not isNear(coords, Config.Entrance) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not at the club entrance.', 'error')
        return
    end

    scanCooldowns[source] = now

    local idCard = Target.Functions.GetItemByName('id_card')
    local fakeId = Target.Functions.GetItemByName('fake_id')

    local result = {
        targetSource = Target.PlayerData.source,
        targetName = Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname,
        hasId = idCard ~= nil,
        hasFakeId = fakeId ~= nil,
        valid = idCard ~= nil and fakeId == nil
    }

    TriggerClientEvent('whellco_id_scanner:result', source, result)
    TriggerClientEvent('whellco_id_scanner:scanned', Target.PlayerData.source, result)
end)

RegisterCommand('scanid', function(source, args)
    local targetSource = args[1]

    if not targetSource then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /scanid [player_id]', 'error')
        return
    end

    TriggerEvent('whellco_id_scanner:scan', targetSource)
end, false)