local QBCore = exports['qb-core']:GetCoreObject()

local ejectCooldowns = {}

local function isSecurity(Player)
    local job = Player.PlayerData.job

    return job and job.name == Config.SecurityJob
end

RegisterNetEvent('whellco_bouncer_eject:eject', function(targetSource, reason)
    local source = source
    local Guard = QBCore.Functions.GetPlayer(source)
    local Target = QBCore.Functions.GetPlayer(tonumber(targetSource) or 0)

    if not Guard or not Target or not isSecurity(Guard) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not authorised to eject players.', 'error')
        return
    end

    local now = os.time()

    if now - (ejectCooldowns[source] or 0) < Config.EjectCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before ejecting another player.', 'error')
        return
    end

    ejectCooldowns[source] = now

    TriggerClientEvent('whellco_bouncer_eject:ejected', Target.PlayerData.source, {
        reason = reason or 'Removed from premises',
        ejectLocation = Config.StripClub.ejectLocation
    })

    TriggerClientEvent('QBCore:Notify', source, ('Ejected %s.'):format(Target.PlayerData.charinfo.firstname), 'success')
end)

RegisterCommand('eject', function(source, args)
    local targetSource = args[1]
    local reason = table.concat(args, ' ', 2)

    if not targetSource then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /eject [player_id] [reason]', 'error')
        return
    end

    TriggerEvent('whellco_bouncer_eject:eject', targetSource, reason)
end, false)