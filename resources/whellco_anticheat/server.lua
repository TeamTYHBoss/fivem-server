local QBCore = exports['qb-core']:GetCoreObject()

local playerScores = {}
local eventCounts = {}
local baseline = {
    eventPerMinute = Config.RateLimits.EventPerMinute,
    moneyPerMinute = Config.RateLimits.MoneyTransactionPerMinute,
    vehiclePerMinute = Config.RateLimits.VehicleSpawnPerMinute,
    itemPerMinute = Config.RateLimits.ItemGivePerMinute
}

local function isAdmin(Player)
    local job = Player.PlayerData.job

    return job and Config.AdminJobs[job.name]
end

local function addScore(source, amount, reason)
    playerScores[source] = (playerScores[source] or 0) + amount

    MySQL.query.await(
        [[INSERT INTO whellco_anticheat_events
            (player_citizenid, detection, score, details)
          VALUES (?, ?, ?, ?)]],
        {
            Player and Player.PlayerData.citizenid or 'unknown',
            reason,
            amount,
            json.encode({source = source, score = playerScores[source]})
        }
    )

    local score = playerScores[source]

    if score >= Config.Enforcement.QuarantineThreshold then
        TriggerEvent('whellco_anticheat:quarantine', source, reason, score)
    elseif score >= Config.Enforcement.KickThreshold then
        DropPlayer(source, 'Anti-cheat: suspicious activity detected. Contact staff if this is an error.')
    elseif score >= Config.Enforcement.WarnThreshold then
        TriggerClientEvent('QBCore:Notify', source, 'Anti-cheat warning: suspicious activity detected.', 'error')
    end
end

local function isRateLimited(source, key, limit)
    local now = os.time()
    local window = math.floor(now / 60)
    local bucket = key .. ':' .. source .. ':' .. window

    eventCounts[bucket] = (eventCounts[bucket] or 0) + 1

    return eventCounts[bucket] > limit
end

RegisterNetEvent('whellco_anticheat:report', function(detection, details)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    if not Config.Detection[detection] then
        return
    end

    addScore(source, 10, detection)
end)

RegisterNetEvent('whellco_anticheat:money', function(amount, context)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    amount = tonumber(amount) or 0

    if amount <= 0 then
        return
    end

    if isRateLimited(source, 'money', baseline.moneyPerMinute) then
        addScore(source, 15, 'money-rate-limit')
        return
    end

    if amount > 100000 then
        addScore(source, 25, 'invalid-money-amount')
    end
end)

RegisterNetEvent('whellco_anticheat:vehicle', function(model)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    if isRateLimited(source, 'vehicle', baseline.vehiclePerMinute) then
        addScore(source, 20, 'vehicle-spam')
    end
end)

RegisterNetEvent('whellco_anticheat:item', function(itemName, amount)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    amount = tonumber(amount) or 0

    if isRateLimited(source, 'item', baseline.itemPerMinute) then
        addScore(source, 20, 'item-spam')
        return
    end

    if amount > 1000 then
        addScore(source, 25, 'invalid-item-amount')
    end
end)

AddEventHandler('playerDropped', function()
    playerScores[source] = nil
end)

RegisterNetEvent('whellco_anticheat:staffReview', function(targetSource, verdict)
    local source = source
    local Admin = QBCore.Functions.GetPlayer(source)
    local Target = QBCore.Functions.GetPlayer(tonumber(targetSource) or 0)

    if not Admin or not Target or not isAdmin(Admin) then
        return
    end

    if verdict == 'false_positive' then
        playerScores[Target.PlayerData.source] = math.max(0, (playerScores[Target.PlayerData.source] or 0) - 30)

        MySQL.query.await(
            [[INSERT INTO whellco_anticheat_feedback
                (staff_citizenid, target_citizenid, detection, verdict)
              VALUES (?, ?, 'manual_review', 'false_positive')]],
            {
                Admin.PlayerData.citizenid,
                Target.PlayerData.citizenid
            }
        )
    end
end)

RegisterNetEvent('whellco_anticheat:quarantine', function(targetSource, reason, score)
    local Target = QBCore.Functions.GetPlayer(targetSource)

    if not Target then
        return
    end

    TriggerClientEvent('QBCore:Notify', targetSource, 'You have been placed in quarantine pending staff review.', 'error')

    MySQL.query.await(
        [[INSERT INTO whellco_anticheat_cases
            (player_citizenid, reason, score, status)
          VALUES (?, ?, ?, 'open')]],
        {
            Target.PlayerData.citizenid,
            reason,
            score
        }
    )
end)

RegisterCommand('anticheatstatus', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isAdmin(Player) then
        return
    end

    TriggerClientEvent('QBCore:Notify', source, ('Anti-cheat score: %s'):format(playerScores[source] or 0), 'primary')
end, false)