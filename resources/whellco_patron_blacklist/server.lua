local QBCore = exports['qb-core']:GetCoreObject()

local blacklistCooldowns = {}

local function isSecurity(Player)
    local job = Player.PlayerData.job

    return job and job.name == Config.SecurityJob
end

local function isBlacklisted(citizenid)
    local count = MySQL.scalar.await(
        [[
            SELECT COUNT(*)
            FROM whellco_patron_blacklist
            WHERE citizenid = ?
              AND active = 1
        ]],
        { citizenid }
    )

    return count and count > 0
end

RegisterNetEvent('whellco_patron_blacklist:add', function(targetSource, reason)
    local source = source
    local Guard = QBCore.Functions.GetPlayer(source)
    local Target = QBCore.Functions.GetPlayer(tonumber(targetSource) or 0)

    if not Guard or not Target or not isSecurity(Guard) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not authorised to blacklist patrons.', 'error')
        return
    end

    local now = os.time()

    if now - (blacklistCooldowns[source] or 0) < Config.BlacklistCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before blacklisting another patron.', 'error')
        return
    end

    if isBlacklisted(Target.PlayerData.citizenid) then
        TriggerClientEvent('QBCore:Notify', source, 'This patron is already blacklisted.', 'error')
        return
    end

    MySQL.query.await(
        [[
            INSERT INTO whellco_patron_blacklist
                (citizenid, added_by, reason, active)
            VALUES (?, ?, ?, 1)
        ]],
        {
            Target.PlayerData.citizenid,
            Guard.PlayerData.citizenid,
            reason or 'Banned from premises'
        }
    )

    blacklistCooldowns[source] = now

    TriggerClientEvent('whellco_patron_blacklist:blacklisted', Target.PlayerData.source, {
        reason = reason or 'Banned from premises',
        ejectLocation = Config.StripClub.ejectLocation
    })

    TriggerClientEvent('QBCore:Notify', source, ('Blacklisted %s.'):format(Target.PlayerData.charinfo.firstname), 'success')
end)

RegisterNetEvent('whellco_patron_blacklist:remove', function(targetSource)
    local source = source
    local Guard = QBCore.Functions.GetPlayer(source)
    local Target = QBCore.Functions.GetPlayer(tonumber(targetSource) or 0)

    if not Guard or not Target or not isSecurity(Guard) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not authorised to remove blacklist entries.', 'error')
        return
    end

    MySQL.update.await(
        [[
            UPDATE whellco_patron_blacklist
            SET active = 0
            WHERE citizenid = ?
              AND active = 1
        ]],
        { Target.PlayerData.citizenid }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Patron removed from blacklist.', 'success')
end)

RegisterCommand('blacklist', function(source, args)
    local targetSource = args[1]
    local reason = table.concat(args, ' ', 2)

    if not targetSource then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /blacklist [player_id] [reason]', 'error')
        return
    end

    TriggerEvent('whellco_patron_blacklist:add', targetSource, reason)
end, false)

RegisterCommand('unblacklist', function(source, args)
    local targetSource = args[1]

    if not targetSource then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /unblacklist [player_id]', 'error')
        return
    end

    TriggerEvent('whellco_patron_blacklist:remove', targetSource)
end, false)