local activeArrests = {}

local function getIdentifier(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')

    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'steam')
    end

    return identifier
end

local function isPolice(source)
    local identifier = getIdentifier(source)

    if not identifier then
        return false
    end

    local duty = MySQL.single.await(
        [[
            SELECT on_duty
            FROM whellco_police_duties
            WHERE character_id = ?
            LIMIT 1
        ]],
        { identifier }
    )

    return duty and duty.on_duty == 1
end

local function sendMenu(source)
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local jobs = {}

    for id, job in pairs(Config.PoliceJobs) do
        jobs[#jobs + 1] = {
            id = id,
            label = job.label,
            rank = job.rank,
            salary = job.salary
        }
    end

    local citations = MySQL.query.await(
        [[
            SELECT id, officer_id, target_id, citation_type, fine, created_at
            FROM whellco_police_citations
            ORDER BY created_at DESC
            LIMIT 25
        ]]
    ) or {}

    local arrests = MySQL.query.await(
        [[
            SELECT id, officer_id, target_id, reason, arrested_at, released_at
            FROM whellco_police_arrests
            ORDER BY arrested_at DESC
            LIMIT 25
        ]]
    ) or {}

    TriggerClientEvent('whellco_police:openMenu', source, {
        jobs = jobs,
        citations = citations,
        arrests = arrests
    })
end

RegisterNetEvent('whellco_police:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_police:closeMenu', function()
    TriggerClientEvent('whellco_police:closeMenu', source)
end)

RegisterNetEvent('whellco_police:toggleDuty', function(jobId)
    local source = source
    local job = Config.PoliceJobs[jobId]

    if not job then
        return
    end

    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local current = MySQL.single.await(
        [[
            SELECT on_duty
            FROM whellco_police_duties
            WHERE character_id = ? AND job_id = ?
            LIMIT 1
        ]],
        { identifier, jobId }
    )

    local newState = 1

    if current and current.on_duty == 1 then
        newState = 0
    end

    MySQL.query.await(
        [[
            INSERT INTO whellco_police_duties
                (character_id, job_id, on_duty)
            VALUES (?, ?, ?)
            ON DUPLICATE KEY UPDATE on_duty = VALUES(on_duty)
        ]],
        { identifier, jobId, newState }
    )

    TriggerClientEvent('whellco_police:notify', source, newState == 1 and 'You are now on duty.' or 'You are now off duty.')
    sendMenu(source)
end)

RegisterNetEvent('whellco_police:issueCitation', function(targetId, citationType)
    local source = source
    local citation = Config.Citations[citationType]

    if not citation then
        return
    end

    if not isPolice(source) then
        TriggerClientEvent('whellco_police:notify', source, 'You must be on duty.')
        return
    end

    local officerId = getIdentifier(source)
    local target = GetPlayerFromServerId(targetId)

    if target == 0 then
        return
    end

    local targetId2 = getIdentifier(target)

    if not officerId or not targetId2 then
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_police_citations
                (officer_id, target_id, citation_type, fine)
            VALUES (?, ?, ?, ?)
        ]],
        { officerId, targetId2, citationType, citation.fine }
    )

    TriggerClientEvent('whellco_police:notify', target, ('You received a %s citation for £%s.'):format(citation.label, citation.fine))
    TriggerClientEvent('whellco_police:notify', source, 'Citation issued.')
end)

RegisterNetEvent('whellco_police:arrestPlayer', function(targetId, reason)
    local source = source

    if not isPolice(source) then
        TriggerClientEvent('whellco_police:notify', source, 'You must be on duty.')
        return
    end

    local officerId = getIdentifier(source)
    local target = GetPlayerFromServerId(targetId)

    if target == 0 then
        return
    end

    local targetId2 = getIdentifier(target)

    if not officerId or not targetId2 then
        return
    end

    if activeArrests[targetId2] then
        TriggerClientEvent('whellco_police:notify', source, 'That player is already arrested.')
        return
    end

    activeArrests[targetId2] = true

    MySQL.insert.await(
        [[
            INSERT INTO whellco_police_arrests
                (officer_id, target_id, reason)
            VALUES (?, ?, ?)
        ]],
        { officerId, targetId2, reason or 'No reason provided' }
    )

    TriggerClientEvent('whellco_police:notify', target, 'You have been arrested.')
    TriggerClientEvent('whellco_police:notify', source, 'Player arrested.')
end)

RegisterNetEvent('whellco_police:releasePlayer', function(targetId)
    local source = source

    if not isPolice(source) then
        TriggerClientEvent('whellco_police:notify', source, 'You must be on duty.')
        return
    end

    local target = GetPlayerFromServerId(targetId)

    if target == 0 then
        return
    end

    local targetId2 = getIdentifier(target)

    if not targetId2 or not activeArrests[targetId2] then
        return
    end

    activeArrests[targetId2] = nil

    MySQL.query.await(
        [[
            UPDATE whellco_police_arrests
            SET released_at = CURRENT_TIMESTAMP
            WHERE target_id = ? AND released_at IS NULL
        ]],
        { targetId2 }
    )

    TriggerClientEvent('whellco_police:notify', target, 'You have been released.')
    TriggerClientEvent('whellco_police:notify', source, 'Player released.')
end)

AddEventHandler('playerDropped', function()
    local identifier = getIdentifier(source)

    if identifier then
        activeArrests[identifier] = nil
    end
end)
