local QBCore = exports['qb-core']:GetCoreObject()

local activeSessions = {}
local lastActivity = {}

local function isStaff(Player)
    local job = Player.PlayerData.job

    return job and Config.StaffJobs[job.name]
end

local function formatDuration(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)

    return ('%dh %dm'):format(hours, minutes)
end

local function endSession(source, Player, reason)
    local session = activeSessions[Player.PlayerData.citizenid]

    if not session then
        return
    end

    local duration = os.time() - session.startedAt

    MySQL.query.await(
        [[UPDATE whellco_staff_idle_duty_sessions
          SET ended_at = FROM_UNIXTIME(?), duration_seconds = ?, end_reason = ?
          WHERE id = ?]],
        {
            os.time(),
            duration,
            reason,
            session.id
        }
    )

    activeSessions[Player.PlayerData.citizenid] = nil

    TriggerClientEvent('QBCore:Notify', source, ('Duty ended automatically: %s. Session duration: %s.'):format(reason, formatDuration(duration)), 'error')
end

RegisterNetEvent('whellco_staff_idle_duty:toggle', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isStaff(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not authorised to use duty tracking.', 'error')
        return
    end

    local citizenid = Player.PlayerData.citizenid
    local session = activeSessions[citizenid]

    if session then
        endSession(source, Player, 'manual')
    else
        local result = MySQL.query.await(
            [[INSERT INTO whellco_staff_idle_duty_sessions
                (staff_citizenid, staff_job, started_at)
              VALUES (?, ?, FROM_UNIXTIME(?))]],
            {
                citizenid,
                Player.PlayerData.job.name,
                os.time()
            }
        )

        activeSessions[citizenid] = {
            id = result.insertId,
            startedAt = os.time()
        }

        lastActivity[source] = os.time()

        TriggerClientEvent('QBCore:Notify', source, 'Duty started. Your session is being tracked.', 'success')
    end
end)

RegisterNetEvent('whellco_staff_idle_duty:activity', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if Player and activeSessions[Player.PlayerData.citizenid] then
        lastActivity[source] = os.time()
    end
end)

RegisterNetEvent('whellco_staff_idle_duty:status', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isStaff(Player) then
        return
    end

    local session = activeSessions[Player.PlayerData.citizenid]

    if not session then
        TriggerClientEvent('QBCore:Notify', source, 'You are currently off duty.', 'primary')
        return
    end

    local duration = os.time() - session.startedAt

    TriggerClientEvent('QBCore:Notify', source, ('On duty for %s.'):format(formatDuration(duration)), 'primary')
end)

AddEventHandler('playerDropped', function()
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    endSession(source, Player, 'disconnect')
end)

CreateThread(function()
    while true do
        Wait(Config.CheckIntervalSeconds * 1000)

        local now = os.time()

        for source, session in pairs(activeSessions) do
            local Player = QBCore.Functions.GetPlayer(source)

            if not Player then
                activeSessions[source] = nil
            else
                local lastActive = lastActivity[source] or session.startedAt

                if now - lastActive >= Config.IdleTimeoutMinutes * 60 then
                    endSession(source, Player, 'idle_timeout')
                end
            end
        end
    end
end)

RegisterCommand(Config.DutyCommand, function(source)
    TriggerEvent('whellco_staff_idle_duty:toggle')
end, false)

RegisterCommand(Config.StatusCommand, function(source)
    TriggerEvent('whellco_staff_idle_duty:status')
end, false)