local QBCore = exports['qb-core']:GetCoreObject()

local intoxication = {}
local checkCooldowns = {}

local function isSecurity(Player)
    local job = Player.PlayerData.job

    return job and job.name == Config.SecurityJob
end

local function getLevel(value)
    for _, level in ipairs(Config.Levels) do
        if value >= level.min and value <= level.max then
            return level.label
        end
    end

    return 'Sober'
end

RegisterNetEvent('whellco_intoxication_meter:check', function(targetSource)
    local source = source
    local Guard = QBCore.Functions.GetPlayer(source)
    local Target = QBCore.Functions.GetPlayer(tonumber(targetSource) or 0)

    if not Guard or not Target or not isSecurity(Guard) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not authorised to check intoxication.', 'error')
        return
    end

    local now = os.time()

    if now - (checkCooldowns[source] or 0) < Config.CheckCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before checking again.', 'error')
        return
    end

    checkCooldowns[source] = now

    local value = intoxication[Target.PlayerData.citizenid] or 0

    local result = {
        targetSource = Target.PlayerData.source,
        targetName = Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname,
        value = value,
        level = getLevel(value)
    }

    TriggerClientEvent('whellco_intoxication_meter:result', source, result)
    TriggerClientEvent('whellco_intoxication_meter:checked', Target.PlayerData.source, result)
end)

RegisterCommand('intoxication', function(source, args)
    local targetSource = args[1]

    if not targetSource then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /intoxication [player_id]', 'error')
        return
    end

    TriggerEvent('whellco_intoxication_meter:check', targetSource)
end, false)