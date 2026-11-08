local QBCore = exports['qb-core']:GetCoreObject()

local investigationCooldowns = {}

local function isPolice(Player)
    local job = Player.PlayerData.job

    return job and job.name == Config.PoliceJob
end

local function getClaim(claimId)
    return MySQL.single.await(
        [[
            SELECT id, citizenid, plate, damage_amount, status
            FROM whellco_insurance_claims
            WHERE id = ?
        ]],
        { tonumber(claimId) or 0 }
    )
end

local function countRecentClaims(citizenid)
    local count = MySQL.scalar.await(
        [[
            SELECT COUNT(*)
            FROM whellco_insurance_claims
            WHERE citizenid = ?
              AND created_at >= DATE_SUB(NOW(), INTERVAL ? HOUR)
        ]],
        { citizenid, Config.SuspicionThresholds.claimWindowHours }
    )

    return tonumber(count) or 0
end

local function flagClaim(claimId, officerCitizenid, reason)
    MySQL.query.await(
        [[
            INSERT INTO whellco_insurance_fraud_cases
                (claim_id, citizenid, officer_citizenid, reason, status)
            VALUES (?, ?, ?, ?, 'open')
        ]],
        { claimId, nil, officerCitizenid, reason }
    )
end

RegisterNetEvent('whellco_insurance_fraud:investigate', function(claimId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isPolice(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not authorised to investigate insurance claims.', 'error')
        return
    end

    local claim = getClaim(claimId)

    if not claim then
        TriggerClientEvent('QBCore:Notify', source, 'Insurance claim not found.', 'error')
        return
    end

    local now = os.time()

    if now - (investigationCooldowns[source] or 0) < Config.InvestigationCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before starting another investigation.', 'error')
        return
    end

    investigationCooldowns[source] = now

    local reasons = {}
    local suspicious = false

    if claim.damage_amount >= Config.SuspicionThresholds.highDamage then
        suspicious = true
        reasons[#reasons + 1] = 'High damage amount'
    end

    local recentClaims = countRecentClaims(claim.citizenid)

    if recentClaims >= Config.SuspicionThresholds.frequentClaims then
        suspicious = true
        reasons[#reasons + 1] = ('Frequent claims: %d in %d hours'):format(recentClaims, Config.SuspicionThresholds.claimWindowHours)
    end

    if not suspicious then
        TriggerClientEvent('QBCore:Notify', source, 'No fraud indicators found.', 'primary')
        return
    end

    flagClaim(claim.id, Player.PlayerData.citizenid, table.concat(reasons, '; '))

    TriggerClientEvent('QBCore:Notify', source, ('Fraud indicators found: %s.'):format(table.concat(reasons, '; ')), 'error')
end)

RegisterNetEvent('whellco_insurance_fraud:resolve', function(claimId, fraudulent)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isPolice(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not authorised to resolve fraud cases.', 'error')
        return
    end

    local claim = getClaim(claimId)

    if not claim then
        TriggerClientEvent('QBCore:Notify', source, 'Insurance claim not found.', 'error')
        return
    end

    local status = fraudulent and 'fraud_confirmed' or 'cleared'

    MySQL.update.await(
        [[
            UPDATE whellco_insurance_fraud_cases
            SET status = ?,
                resolved_by = ?,
                resolved_at = CURRENT_TIMESTAMP
            WHERE claim_id = ?
              AND status = 'open'
        ]],
        { status, Player.PlayerData.citizenid, claim.id }
    )

    if fraudulent then
        MySQL.update.await(
            [[
                UPDATE whellco_insurance_claims
                SET status = 'denied'
                WHERE id = ?
            ]],
            { claim.id }
        )

        local Target = QBCore.Functions.GetPlayerByCitizenId(claim.citizenid)

        if Target then
            Target.Functions.RemoveMoney('bank', Config.FraudFine, 'Insurance fraud fine')
            Target.Functions.SetMetaData('whellco_xp', (Target.PlayerData.metadata.whellco_xp or 0) - Config.FraudPoints)

            TriggerClientEvent('QBCore:Notify', Target.PlayerData.source, ('Insurance fraud confirmed. Fine: %s%d.'):format(Config.CurrencySymbol, Config.FraudFine), 'error', 10000)
        end
    end

    TriggerClientEvent('QBCore:Notify', source, fraudulent and 'Fraud confirmed.' or 'Claim cleared.', 'success')
end)

RegisterCommand('investigateclaim', function(source, args)
    local claimId = args[1]

    if not claimId then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /investigateclaim [claim_id]', 'error')
        return
    end

    TriggerEvent('whellco_insurance_fraud:investigate', claimId)
end, false)

RegisterCommand('resolvefraud', function(source, args)
    local claimId = args[1]
    local fraudulent = args[2] == 'guilty'

    if not claimId then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /resolvefraud [claim_id] [guilty|innocent]', 'error')
        return
    end

    TriggerEvent('whellco_insurance_fraud:resolve', claimId, fraudulent)
end, false)