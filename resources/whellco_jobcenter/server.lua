local activeJobs = {}
local jobCooldowns = {}

local function getIdentifier(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')

    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'steam')
    end

    return identifier
end

local function getApplications(characterId)
    return MySQL.query.await(
        'SELECT job_id, status FROM whellco_job_applications WHERE character_id = ?',
        { characterId }
    ) or {}
end

local function getHistory(characterId)
    return MySQL.query.await(
        'SELECT job_id, payout, xp, completed_at FROM whellco_job_history WHERE character_id = ? ORDER BY completed_at DESC LIMIT 25',
        { characterId }
    ) or {}
end

local function sendMenu(source, characterId)
    local jobs = {}

    for id, job in pairs(Config.Jobs) do
        local remaining = math.max(0, job.cooldown - (GetGameTimer() - (jobCooldowns[characterId] or 0)))

        jobs[#jobs + 1] = {
            id = id,
            label = job.label,
            description = job.description,
            payout = job.payout,
            xp = job.xp,
            requiredLevel = job.requiredLevel,
            cooldownRemaining = remaining
        }
    end

    TriggerClientEvent('whellco_jobcenter:openMenu', source, {
        jobs = jobs,
        applications = getApplications(characterId),
        history = getHistory(characterId)
    })
end

RegisterNetEvent('whellco_jobcenter:openMenu', function()
    local source = source
    local characterId = GetPlayerIdentifierByType(source, 'license')

    if not characterId then
        return
    end

    sendMenu(source, characterId)
end)

RegisterNetEvent('whellco_jobcenter:closeMenu', function()
    local source = source

    TriggerClientEvent('whellco_jobcenter:closeMenu', source)
end)

RegisterNetEvent('whellco_jobcenter:applyForJob', function(jobId)
    local source = source
    local job = Config.Jobs[jobId]

    if not job then
        return
    end

    local characterId = GetPlayerIdentifierByType(source, 'license')

    if not characterId then
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_job_applications
                (character_id, job_id, status)
            VALUES (?, ?, 'pending')
            ON DUPLICATE KEY UPDATE status = VALUES(status)
        ]],
        { characterId, jobId }
    )

    sendMenu(source, characterId)
end)

RegisterNetEvent('whellco_jobcenter:startJob', function(jobId)
    local source = source
    local job = Config.Jobs[jobId]

    if not job then
        return
    end

    local characterId = GetPlayerIdentifierByType(source, 'license')

    if not characterId then
        return
    end

    local application = MySQL.single.await(
        [[
            SELECT status
            FROM whellco_job_applications
            WHERE character_id = ? AND job_id = ?
            LIMIT 1
        ]],
        { characterId, jobId }
    )

    if not application or application.status ~= 'accepted' then
        TriggerClientEvent('whellco_jobcenter:notify', source, 'You must be accepted for this job first.')
        return
    end

    if activeJobs[characterId] then
        TriggerClientEvent('whellco_jobcenter:notify', source, 'You are already on a job.')
        return
    end

    local now = GetGameTimer()

    if now - (jobCooldowns[characterId] or 0) < job.cooldown then
        TriggerClientEvent('whellco_jobcenter:notify', source, 'You need to wait before starting this job again.')
        return
    end

    activeJobs[characterId] = {
        id = jobId,
        startedAt = now
    }

    TriggerClientEvent('whellco_jobcenter:notify', source, ('Started %s job.'):format(job.label))
end)

RegisterNetEvent('whellco_jobcenter:completeJob', function(jobId)
    local source = source
    local job = Config.Jobs[jobId]

    if not job then
        return
    end

    local characterId = GetPlayerIdentifierByType(source, 'license')
    local active = activeJobs[characterId]

    if not active or active.id ~= jobId then
        return
    end

    MySQL.transaction.await({
        {
            query = [[
                INSERT INTO whellco_job_history
                    (character_id, job_id, payout, xp)
                VALUES (?, ?, ?, ?)
            ]],
            values = { characterId, jobId, job.payout, job.xp }
        },
        {
            query = [[
                UPDATE whellco_job_applications
                SET status = 'accepted'
                WHERE character_id = ? AND job_id = ?
            ]],
            values = { characterId, jobId }
        }
    })

    jobCooldowns[characterId] = GetGameTimer()
    activeJobs[characterId] = nil

    TriggerClientEvent('whellco_jobcenter:notify', source, ('Completed %s job.'):format(job.label))
end)

AddEventHandler('playerDropped', function()
    local characterId = GetPlayerIdentifierByType(source, 'license')

    if characterId then
        activeJobs[characterId] = nil
    end
end)
