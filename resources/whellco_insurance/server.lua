local function getIdentifier(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')

    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'steam')
    end

    return identifier
end

local function sendMenu(source)
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local plans = {}

    for id, plan in pairs(Config.InsurancePlans) do
        plans[#plans + 1] = {
            id = id,
            label = plan.label,
            monthlyPrice = plan.monthlyPrice,
            claimLimit = plan.claimLimit,
            deductible = plan.deductible
        }
    end

    local policies = MySQL.query.await(
        [[
            SELECT id, vehicle_id, plan, active, started_at, expires_at
            FROM whellco_insurance_policies
            WHERE character_id = ?
            ORDER BY started_at DESC
        ]],
        { identifier }
    ) or {}

    local claims = MySQL.query.await(
        [[
            SELECT id, policy_id, vehicle_id, damage_amount, payout, status, created_at, resolved_at
            FROM whellco_insurance_claims
            ORDER BY created_at DESC
            LIMIT 25
        ]]
    ) or {}

    TriggerClientEvent('whellco_insurance:openMenu', source, {
        plans = plans,
        policies = policies,
        claims = claims
    })
end

RegisterNetEvent('whellco_insurance:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_insurance:closeMenu', function()
    TriggerClientEvent('whellco_insurance:closeMenu', source)
end)

RegisterNetEvent('whellco_insurance:buyPolicy', function(vehicleId, planId)
    local source = source
    local identifier = getIdentifier(source)
    local plan = Config.InsurancePlans[planId]

    if not plan then
        return
    end

    if not identifier then
        return
    end

    local vehicle = MySQL.single.await(
        [[
            SELECT id
            FROM whellco_vehicles
            WHERE id = ? AND owner_id = ?
            LIMIT 1
        ]],
        { vehicleId, identifier }
    )

    if not vehicle then
        return
    end

    MySQL.query.await(
        [[
            INSERT INTO whellco_insurance_policies
                (character_id, vehicle_id, plan, active)
            VALUES (?, ?, ?, 1)
            ON DUPLICATE KEY UPDATE plan = VALUES(plan), active = 1, expires_at = NULL
        ]],
        { identifier, vehicleId, planId }
    )

    TriggerClientEvent('whellco_insurance:notify', source, ('%s purchased for £%s per month.'):format(plan.label, plan.monthlyPrice))
    sendMenu(source)
end)

RegisterNetEvent('whellco_insurance:cancelPolicy', function(policyId)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    MySQL.query.await(
        [[
            UPDATE whellco_insurance_policies
            SET active = 0, expires_at = CURRENT_TIMESTAMP
            WHERE id = ? AND character_id = ?
        ]],
        { policyId, identifier }
    )

    TriggerClientEvent('whellco_insurance:notify', source, 'Insurance policy cancelled.')
    sendMenu(source)
end)

RegisterNetEvent('whellco_insurance:submitClaim', function(policyId, damageAmount)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local policy = MySQL.single.await(
        [[
            SELECT id, vehicle_id, plan, active
            FROM whellco_insurance_policies
            WHERE id = ? AND character_id = ?
            LIMIT 1
        ]],
        { policyId, identifier }
    )

    if not policy or policy.active ~= 1 then
        TriggerClientEvent('whellco_insurance:notify', source, 'You do not have an active policy.')
        return
    end

    local plan = Config.InsurancePlans[policy.plan]

    if not plan then
        return
    end

    local damage = tonumber(damageAmount) or 0

    if damage <= 0 then
        return
    end

    local payout = math.min(damage, plan.claimLimit) - plan.deductible

    if payout < 0 then
        payout = 0
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_insurance_claims
                (policy_id, vehicle_id, damage_amount, payout, status)
            VALUES (?, ?, ?, ?, 'approved')
        ]],
        { policyId, policy.vehicle_id, damage, payout }
    )

    TriggerClientEvent('whellco_insurance:notify', source, ('Claim approved. Insurance will cover £%s.'):format(payout))
    sendMenu(source)
end)

RegisterNetEvent('whellco_insurance:repairVehicle', function(vehicleId, repairCost)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local policy = MySQL.single.await(
        [[
            SELECT id, plan, active
            FROM whellco_insurance_policies
            WHERE vehicle_id = ? AND character_id = ?
            LIMIT 1
        ]],
        { vehicleId, identifier }
    )

    local cost = tonumber(repairCost) or 0

    if cost <= 0 then
        return
    end

    local covered = 0

    if policy and policy.active == 1 then
        local plan = Config.InsurancePlans[policy.plan]

        if plan then
            covered = math.min(cost, plan.claimLimit) - plan.deductible

            if covered < 0 then
                covered = 0
            end
        end
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_insurance_repairs
                (vehicle_id, repair_cost, insurance_covered)
            VALUES (?, ?, ?)
        ]],
        { vehicleId, cost, covered }
    )

    TriggerClientEvent('whellco_insurance:notify', source, ('Repair recorded. Insurance covered £%s.'):format(covered))
    sendMenu(source)
end)
