local function getIdentifier(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')

    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'steam')
    end

    return identifier
end

local function isMedical(source)
    local identifier = getIdentifier(source)

    if not identifier then
        return false
    end

    local duty = MySQL.single.await(
        [[
            SELECT on_duty
            FROM whellco_medical_duties
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

    for id, job in pairs(Config.MedicalJobs) do
        jobs[#jobs + 1] = {
            id = id,
            label = job.label,
            rank = job.rank,
            salary = job.salary
        }
    end

    local injuries = MySQL.query.await(
        [[
            SELECT id, character_id, injury_type, severity, healed, created_at, healed_at
            FROM whellco_medical_injuries
            ORDER BY created_at DESC
            LIMIT 25
        ]]
    ) or {}

    local treatments = MySQL.query.await(
        [[
            SELECT id, medic_id, patient_id, injury_type, treatment, treated_at
            FROM whellco_medical_treatments
            ORDER BY treated_at DESC
            LIMIT 25
        ]]
    ) or {}

    TriggerClientEvent('whellco_medical:openMenu', source, {
        jobs = jobs,
        injuries = injuries,
        treatments = treatments
    })
end

RegisterNetEvent('whellco_medical:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_medical:closeMenu', function()
    TriggerClientEvent('whellco_medical:closeMenu', source)
end)

RegisterNetEvent('whellco_medical:toggleDuty', function(jobId)
    local source = source
    local job = Config.MedicalJobs[jobId]

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
            FROM whellco_medical_duties
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
            INSERT INTO whellco_medical_duties
                (character_id, job_id, on_duty)
            VALUES (?, ?, ?)
            ON DUPLICATE KEY UPDATE on_duty = VALUES(on_duty)
        ]],
        { identifier, jobId, newState }
    )

    TriggerClientEvent('whellco_medical:notify', source, newState == 1 and 'You are now on duty.' or 'You are now off duty.')
    sendMenu(source)
end)

RegisterNetEvent('whellco_medical:treatPatient', function(targetId, injuryType, treatment)
    local source = source

    if not isMedical(source) then
        TriggerClientEvent('whellco_medical:notify', source, 'You must be on duty.')
        return
    end

    local medicId = getIdentifier(source)
    local target = GetPlayerFromServerId(targetId)

    if target == 0 then
        return
    end

    local patientId = getIdentifier(target)

    if not medicId or not patientId then
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_medical_treatments
                (medic_id, patient_id, injury_type, treatment)
            VALUES (?, ?, ?, ?)
        ]],
        { medicId, patientId, injuryType, treatment or 'No treatment provided' }
    )

    TriggerClientEvent('whellco_medical:notify', target, 'You have been treated by medical staff.')
    TriggerClientEvent('whellco_medical:notify', source, 'Treatment recorded.')
end)

RegisterNetEvent('whellco_medical:healPatient', function(targetId)
    local source = source

    if not isMedical(source) then
        TriggerClientEvent('whellco_medical:notify', source, 'You must be on duty.')
        return
    end

    local target = GetPlayerFromServerId(targetId)

    if target == 0 then
        return
    end

    local patientId = getIdentifier(target)

    if not patientId then
        return
    end

    MySQL.query.await(
        [[
            UPDATE whellco_medical_injuries
            SET healed = 1, healed_at = CURRENT_TIMESTAMP
            WHERE character_id = ? AND healed = 0
        ]],
        { patientId }
    )

    TriggerClientEvent('whellco_medical:notify', target, 'You have been healed.')
    TriggerClientEvent('whellco_medical:notify', source, 'Patient healed.')
end)

AddEventHandler('playerDropped', function()
    local identifier = getIdentifier(source)

    if identifier then
        MySQL.query.await(
            [[
                UPDATE whellco_medical_duties
                SET on_duty = 0
                WHERE character_id = ?
            ]],
            { identifier }
        )
    end
end)
