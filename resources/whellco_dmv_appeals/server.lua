local QBCore = exports['qb-core']:GetCoreObject()

local appealCooldowns = {}
local activeService = {}

local function isPolice(Player)
    local job = Player.PlayerData.job

    return job and job.name == Config.PoliceJob
end

local function isNear(coords, location)
    return #(coords - location) <= 10.0
end

RegisterNetEvent('whellco_dmv_appeals:submit', function(fineId, reason)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    fineId = tonumber(fineId) or 0

    if type(reason) ~= 'string' or reason == '' or #reason > Config.MaxAppealTextLength then
        TriggerClientEvent('QBCore:Notify', source, 'Provide a valid appeal reason.', 'error')
        return
    end

    local now = os.time()

    if now - (appealCooldowns[source] or 0) < Config.AppealCooldownMinutes * 60 then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before submitting another appeal.', 'error')
        return
    end

    local fine = MySQL.single.await(
        [[
            SELECT id, citizenid, status
            FROM whellco_traffic_fines
            WHERE id = ?
        ]],
        { fineId }
    )

    if not fine or fine.citizenid ~= Player.PlayerData.citizenid then
        TriggerClientEvent('QBCore:Notify', source, 'Fine not found.', 'error')
        return
    end

    if fine.status ~= 'unpaid' then
        TriggerClientEvent('QBCore:Notify', source, 'Only unpaid fines can be appealed.', 'error')
        return
    end

    MySQL.query.await(
        [[
            INSERT INTO whellco_dmv_appeals
                (citizenid, fine_id, reason, status)
            VALUES (?, ?, ?, 'pending')
        ]],
        { Player.PlayerData.citizenid, fineId, reason }
    )

    appealCooldowns[source] = now

    TriggerClientEvent('QBCore:Notify', source, 'Appeal submitted for review.', 'success')
end)

RegisterNetEvent('whellco_dmv_appeals:review', function(appealId, approved)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isPolice(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not authorised to review appeals.', 'error')
        return
    end

    appealId = tonumber(appealId) or 0
    approved = approved == true

    local appeal = MySQL.single.await(
        [[
            SELECT id, citizenid, fine_id, status
            FROM whellco_dmv_appeals
            WHERE id = ?
        ]],
        { appealId }
    )

    if not appeal or appeal.status ~= 'pending' then
        TriggerClientEvent('QBCore:Notify', source, 'Appeal not found or already reviewed.', 'error')
        return
    end

    MySQL.update.await(
        [[
            UPDATE whellco_dmv_appeals
            SET status = ?,
                reviewed_by = ?,
                reviewed_at = CURRENT_TIMESTAMP
            WHERE id = ?
        ]],
        {
            approved and 'approved' or 'denied',
            Player.PlayerData.citizenid,
            appealId
        }
    )

    if approved then
        MySQL.update.await(
            [[
                UPDATE whellco_traffic_fines
                SET status = 'dismissed'
                WHERE id = ?
            ]],
            { appeal.fine_id }
        )
    end

    TriggerClientEvent('QBCore:Notify', source, approved and 'Appeal approved.' or 'Appeal denied.', 'success')
end)

RegisterNetEvent('whellco_dmv_appeals:startService', function(appealId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    appealId = tonumber(appealId) or 0

    local appeal = MySQL.single.await(
        [[
            SELECT id, citizenid, status
            FROM whellco_dmv_appeals
            WHERE id = ?
        ]],
        { appealId }
    )

    if not appeal or appeal.citizenid ~= Player.PlayerData.citizenid then
        TriggerClientEvent('QBCore:Notify', source, 'Appeal not found.', 'error')
        return
    end

    if appeal.status ~= 'pending' then
        TriggerClientEvent('QBCore:Notify', source, 'This appeal is not eligible for community service.', 'error')
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if not isNear(coords, Config.CommunityService.location) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not at the community service location.', 'error')
        return
    end

    activeService[source] = {
        appealId = appealId,
        points = 0
    }

    TriggerClientEvent('QBCore:Notify', source, ('Community service started. Complete %d task(s).'):format(Config.CommunityService.maxPointsPerAppeal), 'primary')
end)

RegisterNetEvent('whellco_dmv_appeals:completeTask', function()
    local source = source
    local service = activeService[source]

    if not service then
        return
    end

    service.points = service.points + Config.CommunityService.pointsPerTask

    if service.points >= Config.CommunityService.maxPointsPerAppeal then
        activeService[source] = nil

        MySQL.update.await(
            [[
                UPDATE whellco_dmv_appeals
                SET status = 'community_service',
                    reviewed_by = NULL,
                    reviewed_at = CURRENT_TIMESTAMP
                WHERE id = ?
            ]],
            { service.appealId }
        )

        TriggerClientEvent('QBCore:Notify', source, 'Community service completed.', 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, ('Community service progress: %d/%d.'):format(service.points, Config.CommunityService.maxPointsPerAppeal), 'primary')
    end
end)

RegisterCommand('appealfine', function(source, args)
    local fineId = args[1]
    local reason = table.concat(args, ' ', 2)

    if not fineId or reason == '' then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /appealfine [fine_id] [reason]', 'error')
        return
    end

    TriggerEvent('whellco_dmv_appeals:submit', fineId, reason)
end, false)

RegisterCommand('reviewappeal', function(source, args)
    local appealId = args[1]
    local approved = args[2] == 'approve'

    if not appealId then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /reviewappeal [appeal_id] [approve|deny]', 'error')
        return
    end

    TriggerEvent('whellco_dmv_appeals:review', appealId, approved)
end, false)

RegisterCommand('startservice', function(source, args)
    local appealId = args[1]

    if not appealId then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /startservice [appeal_id]', 'error')
        return
    end

    TriggerEvent('whellco_dmv_appeals:startService', appealId)
end, false)

RegisterCommand('doservice', function()
    TriggerEvent('whellco_dmv_appeals:completeTask')
end, false)