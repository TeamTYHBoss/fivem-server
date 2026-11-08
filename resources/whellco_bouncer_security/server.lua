local QBCore = exports['qb-core']:GetCoreObject()

local escortCooldowns = {}

local function isSecurity(Player)
    local job = Player.PlayerData.job

    return job and job.name == Config.SecurityJob
end

RegisterNetEvent('whellco_bouncer_security:escort', function(targetSource, reason)
    local source = source
    local Guard = QBCore.Functions.GetPlayer(source)
    local Target = QBCore.Functions.GetPlayer(tonumber(targetSource) or 0)

    if not Guard or not Target or not isSecurity(Guard) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not authorised to escort players.', 'error')
        return
    end

    local now = os.time()

    if now - (escortCooldowns[source] or 0) < Config.EscortCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before escorting another player.', 'error')
        return
    end

    escortCooldowns[source] = now

    TriggerClientEvent('whellco_bouncer_security:escort', Target.PlayerData.source, {
        guardSource = source,
        reason = reason or 'Disruptive behaviour',
        ejectLocation = Config.StripClub.ejectLocation,
        duration = Config.EscortDuration
    })

    TriggerClientEvent('QBCore:Notify', source, ('Escorting %s out.'):format(Target.PlayerData.charinfo.firstname), 'success')
end)

RegisterCommand('escort', function(source, args)
    local targetSource = args[1]
    local reason = table.concat(args, ' ', 2)

    if not targetSource then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /escort [player_id] [reason]', 'error')
        return
    end

    TriggerEvent('whellco_bouncer_security:escort', targetSource, reason)
end, false)