local function getIdentifier(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')

    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'steam')
    end

    return identifier
end

local function isMechanic(source)
    local identifier = getIdentifier(source)

    if not identifier then
        return false
    end

    local duty = MySQL.single.await(
        [[
            SELECT on_duty
            FROM whellco_mechanic_duties
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

    for id, job in pairs(Config.MechanicJobs) do
        jobs[#jobs + 1] = {
            id = id,
            label = job.label,
            rank = job.rank,
            salary = job.salary
        }
    end

    local repairs = MySQL.query.await(
        [[
            SELECT id, mechanic_id, vehicle_plate, repair_type, price, repaired_at
            FROM whellco_mechanic_repairs
            ORDER BY repaired_at DESC
            LIMIT 25
        ]]
    ) or {}

    local upgrades = MySQL.query.await(
        [[
            SELECT id, mechanic_id, vehicle_plate, upgrade_type, price, upgraded_at
            FROM whellco_mechanic_upgrades
            ORDER BY upgraded_at DESC
            LIMIT 25
        ]]
    ) or {}

    TriggerClientEvent('whellco_mechanic:openMenu', source, {
        jobs = jobs,
        repairs = repairs,
        upgrades = upgrades
    })
end

RegisterNetEvent('whellco_mechanic:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_mechanic:closeMenu', function()
    TriggerClientEvent('whellco_mechanic:closeMenu', source)
end)

RegisterNetEvent('whellco_mechanic:toggleDuty', function(jobId)
    local source = source
    local job = Config.MechanicJobs[jobId]

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
            FROM whellco_mechanic_duties
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
            INSERT INTO whellco_mechanic_duties
                (character_id, job_id, on_duty)
            VALUES (?, ?, ?)
            ON DUPLICATE KEY UPDATE on_duty = VALUES(on_duty)
        ]],
        { identifier, jobId, newState }
    )

    TriggerClientEvent('whellco_mechanic:notify', source, newState == 1 and 'You are now on duty.' or 'You are now off duty.')
    sendMenu(source)
end)

RegisterNetEvent('whellco_mechanic:repairVehicle', function(plate, repairType)
    local source = source
    local repair = Config.Repairs[repairType]

    if not repair then
        return
    end

    if not isMechanic(source) then
        TriggerClientEvent('whellco_mechanic:notify', source, 'You must be on duty.')
        return
    end

    local mechanicId = getIdentifier(source)

    if not mechanicId or not plate then
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_mechanic_repairs
                (mechanic_id, vehicle_plate, repair_type, price)
            VALUES (?, ?, ?, ?)
        ]],
        { mechanicId, plate, repairType, repair.price }
    )

    TriggerClientEvent('whellco_mechanic:notify', source, ('%s completed for £%s.'):format(repair.label, repair.price))
end)

RegisterNetEvent('whellco_mechanic:upgradeVehicle', function(plate, upgradeType)
    local source = source
    local upgrade = Config.Upgrades[upgradeType]

    if not upgrade then
        return
    end

    if not isMechanic(source) then
        TriggerClientEvent('whellco_mechanic:notify', source, 'You must be on duty.')
        return
    end

    local mechanicId = getIdentifier(source)

    if not mechanicId or not plate then
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_mechanic_upgrades
                (mechanic_id, vehicle_plate, upgrade_type, price)
            VALUES (?, ?, ?, ?)
        ]],
        { mechanicId, plate, upgradeType, upgrade.price }
    )

    TriggerClientEvent('whellco_mechanic:notify', source, ('%s completed for £%s.'):format(upgrade.label, upgrade.price))
end)

AddEventHandler('playerDropped', function()
    local identifier = getIdentifier(source)

    if identifier then
        MySQL.query.await(
            [[
                UPDATE whellco_mechanic_duties
                SET on_duty = 0
                WHERE character_id = ?
            ]],
            { identifier }
        )
    end
end)
