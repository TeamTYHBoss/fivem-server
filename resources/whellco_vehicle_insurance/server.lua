local QBCore = exports['qb-core']:GetCoreObject()

local claimCooldowns = {}

local function isNear(coords, office)
    return #(coords - office.location) <= office.radius
end

local function getPolicy(citizenid)
    return MySQL.single.await(
        [[
            SELECT id, policy_type, status
            FROM whellco_vehicle_insurance
            WHERE citizenid = ?
            ORDER BY created_at DESC
            LIMIT 1
        ]],
        { citizenid }
    )
end

local function ownsVehicle(Player, plate)
    local count = MySQL.scalar.await(
        [[
            SELECT COUNT(*)
            FROM player_vehicles
            WHERE citizenid = ?
              AND plate = ?
        ]],
        { Player.PlayerData.citizenid, plate }
    )

    return count and count > 0
end

RegisterNetEvent('whellco_vehicle_insurance:purchase', function(policyType)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local policy = Config.Policies[policyType]

    if not Player or not policy then
        TriggerClientEvent('QBCore:Notify', source, 'Insurance policy not found.', 'error')
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if not isNear(coords, Config.InsuranceOffice) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not at the insurance office.', 'error')
        return
    end

    if Player.Functions.GetMoney('bank') < policy.monthlyPrice then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough money in your bank account.', 'error')
        return
    end

    Player.Functions.RemoveMoney('bank', policy.monthlyPrice, ('Insurance purchase: %s'):format(policyType))

    MySQL.query.await(
        [[
            INSERT INTO whellco_vehicle_insurance
                (citizenid, policy_type, status)
            VALUES (?, ?, 'active')
        ]],
        { Player.PlayerData.citizenid, policyType }
    )

    TriggerClientEvent('QBCore:Notify', source, ('Purchased %s for %s%d.'):format(policy.label, Config.CurrencySymbol, policy.monthlyPrice), 'success')
end)

RegisterNetEvent('whellco_vehicle_insurance:claim', function(plate, damageAmount, description)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local policy = getPolicy(Player.PlayerData.citizenid)
    local policyConfig = policy and Config.Policies[policy.policy_type]

    if not Player or not policy or policy.status ~= 'active' or not policyConfig then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have active insurance.', 'error')
        return
    end

    plate = tostring(plate or '')
    damageAmount = math.floor(tonumber(damageAmount) or 0)

    if plate == '' or damageAmount < Config.DamageThreshold then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid claim details.', 'error')
        return
    end

    if not ownsVehicle(Player, plate) then
        TriggerClientEvent('QBCore:Notify', source, 'You do not own this vehicle.', 'error')
        return
    end

    local now = os.time()

    if now - (claimCooldowns[source] or 0) < Config.ClaimCooldownMinutes * 60 then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before submitting another claim.', 'error')
        return
    end

    local deductible = math.floor(damageAmount * (Config.DeductiblePercent / 100))
    local payout = math.min(policyConfig.maxPayout, damageAmount - deductible)

    if payout <= 0 then
        TriggerClientEvent('QBCore:Notify', source, 'Claim amount is too low for a payout.', 'error')
        return
    end

    MySQL.query.await(
        [[
            INSERT INTO whellco_insurance_claims
                (citizenid, plate, policy_type, damage_amount, deductible, payout, description, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, 'pending')
        ]],
        {
            Player.PlayerData.citizenid,
            plate,
            policy.policy_type,
            damageAmount,
            deductible,
            payout,
            description or 'Vehicle crash claim'
        }
    )

    claimCooldowns[source] = now

    TriggerClientEvent('QBCore:Notify', source, ('Claim submitted. Estimated payout: %s%d.'):format(Config.CurrencySymbol, payout), 'success')
end)

RegisterNetEvent('whellco_vehicle_insurance:approve', function(claimId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    claimId = tonumber(claimId) or 0

    local claim = MySQL.single.await(
        [[
            SELECT id, citizenid, payout, status
            FROM whellco_insurance_claims
            WHERE id = ?
        ]],
        { claimId }
    )

    if not claim or claim.citizenid ~= Player.PlayerData.citizenid then
        TriggerClientEvent('QBCore:Notify', source, 'Claim not found.', 'error')
        return
    end

    if claim.status ~= 'pending' then
        TriggerClientEvent('QBCore:Notify', source, 'This claim has already been processed.', 'error')
        return
    end

    Player.Functions.AddMoney('bank', claim.payout, ('Insurance payout: %d'):format(claim.id))

    MySQL.update.await(
        [[
            UPDATE whellco_insurance_claims
            SET status = 'approved',
                approved_at = CURRENT_TIMESTAMP
            WHERE id = ?
        ]],
        { claim.id }
    )

    TriggerClientEvent('QBCore:Notify', source, ('Insurance claim approved. Payout: %s%d.'):format(Config.CurrencySymbol, claim.payout), 'success')
end)

RegisterCommand('insurance', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local names = {}

    for policyType, policy in pairs(Config.Policies) do
        names[#names + 1] = ('%s - %s ($%d/month)'):format(policyType, policy.label, policy.monthlyPrice)
    end

    TriggerClientEvent('QBCore:Notify', source, table.concat(names, ', '), 'primary')
end, false)

RegisterCommand('buyinsurance', function(source, args)
    local policyType = args[1]

    if not policyType then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /buyinsurance [policy_type]', 'error')
        return
    end

    TriggerEvent('whellco_vehicle_insurance:purchase', policyType)
end, false)

RegisterCommand('claiminsurance', function(source, args)
    local plate = args[1]
    local damageAmount = tonumber(args[2])
    local description = table.concat(args, ' ', 3)

    if not plate or not damageAmount then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /claiminsurance [plate] [damage_amount] [description]', 'error')
        return
    end

    TriggerEvent('whellco_vehicle_insurance:claim', plate, damageAmount, description)
end, false)

RegisterCommand('approveclaim', function(source, args)
    local claimId = args[1]

    if not claimId then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /approveclaim [claim_id]', 'error')
        return
    end

    TriggerEvent('whellco_vehicle_insurance:approve', claimId)
end, false)