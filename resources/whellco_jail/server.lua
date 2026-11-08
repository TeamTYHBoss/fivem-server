local QBCore = exports['qb-core']:GetCoreObject()

local function isPolice(Player)
    local job = Player.PlayerData.job

    return job and Config.PoliceJobs[job.name]
end

local function getActiveSentence(citizenId)
    return MySQL.single.await(
        [[
            SELECT id, sentence_minutes, remaining_minutes, facility
            FROM whellco_jail_sentences
            WHERE citizenid = ?
              AND released = 0
            ORDER BY created_at DESC
            LIMIT 1
        ]],
        { citizenId }
    )
end

RegisterNetEvent('whellco_jail:jailPlayer', function(targetSource, minutes, reason)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local Target = QBCore.Functions.GetPlayer(targetSource)

    if not Player or not Target or not isPolice(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have permission to jail players.', 'error')
        return
    end

    minutes = math.floor(tonumber(minutes) or 0)

    if minutes < Config.MinSentenceMinutes or minutes > Config.MaxSentenceMinutes then
        TriggerClientEvent('QBCore:Notify', source, ('Sentence must be between %d and %d minutes.'):format(Config.MinSentenceMinutes, Config.MaxSentenceMinutes), 'error')
        return
    end

    reason = tostring(reason or ''):sub(1, 180)

    local existing = getActiveSentence(Target.PlayerData.citizenid)

    if existing then
        TriggerClientEvent('QBCore:Notify', source, 'Player is already incarcerated.', 'error')
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_jail_sentences
                (citizenid, sentence_minutes, remaining_minutes, reason, facility)
            VALUES (?, ?, ?, ?, 'jail')
        ]],
        { Target.PlayerData.citizenid, minutes, minutes, reason }
    )

    TriggerClientEvent('whellco_jail:teleport', targetSource, {
        coords = Config.Jail.entrance,
        facility = 'jail',
        minutes = minutes,
        reason = reason
    })

    TriggerClientEvent('QBCore:Notify', source, ('Jailed %s for %d minute(s).'):format(Target.PlayerData.charinfo.firstname, minutes), 'success')
end)

RegisterNetEvent('whellco_jail:prisonPlayer', function(targetSource, minutes, reason)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local Target = QBCore.Functions.GetPlayer(targetSource)

    if not Player or not Target or not isPolice(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have permission to imprison players.', 'error')
        return
    end

    minutes = math.floor(tonumber(minutes) or 0)

    if minutes < Config.MinSentenceMinutes or minutes > Config.MaxSentenceMinutes then
        TriggerClientEvent('QBCore:Notify', source, ('Sentence must be between %d and %d minutes.'):format(Config.MinSentenceMinutes, Config.MaxSentenceMinutes), 'error')
        return
    end

    reason = tostring(reason or ''):sub(1, 180)

    local existing = getActiveSentence(Target.PlayerData.citizenid)

    if existing then
        TriggerClientEvent('QBCore:Notify', source, 'Player is already incarcerated.', 'error')
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_jail_sentences
                (citizenid, sentence_minutes, remaining_minutes, reason, facility)
            VALUES (?, ?, ?, ?, 'prison')
        ]],
        { Target.PlayerData.citizenid, minutes, minutes, reason }
    )

    TriggerClientEvent('whellco_jail:teleport', targetSource, {
        coords = Config.Prison.entrance,
        facility = 'prison',
        minutes = minutes,
        reason = reason
    })

    TriggerClientEvent('QBCore:Notify', source, ('Imprisoned %s for %d minute(s).'):format(Target.PlayerData.charinfo.firstname, minutes), 'success')
end)

RegisterNetEvent('whellco_jail:releasePlayer', function(targetSource)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local Target = QBCore.Functions.GetPlayer(targetSource)

    if not Player or not Target or not isPolice(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have permission to release players.', 'error')
        return
    end

    local sentence = getActiveSentence(Target.PlayerData.citizenid)

    if not sentence then
        TriggerClientEvent('QBCore:Notify', source, 'Player is not incarcerated.', 'error')
        return
    end

    MySQL.update.await(
        [[
            UPDATE whellco_jail_sentences
            SET released = 1, remaining_minutes = 0
            WHERE id = ?
        ]],
        { sentence.id }
    )

    TriggerClientEvent('whellco_jail:release', targetSource, {
        facility = sentence.facility
    })

    TriggerClientEvent('QBCore:Notify', source, 'Player released.', 'success')
end)

RegisterNetEvent('whellco_jail:completeJob', function(jobIndex)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local sentence = getActiveSentence(Player.PlayerData.citizenid)

    if not Player or not sentence then
        return
    end

    local jobs = sentence.facility == 'prison' and Config.PrisonJobs or Config.JailJobs
    local job = jobs[jobIndex]

    if not job then
        return
    end

    Player.Functions.AddMoney('cash', job.reward, ('Completed %s'):format(job.label))
    Player.Functions.SetMetaData('whellco_xp', (Player.PlayerData.metadata.whellco_xp or 0) + job.xp)

    TriggerClientEvent('QBCore:Notify', source, ('Completed %s. Earned $%d and %d XP.'):format(job.label, job.reward, job.xp), 'success')
end)

RegisterCommand('jail', function(source, args)
    local targetSource = tonumber(args[1])
    local minutes = tonumber(args[2])
    local reason = table.concat(args, ' ', 3)

    if not targetSource or not minutes then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /jail [source] [minutes] [reason]', 'error')
        return
    end

    TriggerEvent('whellco_jail:jailPlayer', targetSource, minutes, reason)
end, false)

RegisterCommand('prison', function(source, args)
    local targetSource = tonumber(args[1])
    local minutes = tonumber(args[2])
    local reason = table.concat(args, ' ', 3)

    if not targetSource or not minutes then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /prison [source] [minutes] [reason]', 'error')
        return
    end

    TriggerEvent('whellco_jail:prisonPlayer', targetSource, minutes, reason)
end, false)

RegisterCommand('release', function(source, args)
    local targetSource = tonumber(args[1])

    if not targetSource then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /release [source]', 'error')
        return
    end

    TriggerEvent('whellco_jail:releasePlayer', targetSource)
end, false)