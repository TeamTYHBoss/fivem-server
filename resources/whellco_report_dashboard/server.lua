local QBCore = exports['qb-core']:GetCoreObject()

local actionCooldowns = {}

local function isStaff(Player)
    local job = Player.PlayerData.job

    return job and Config.StaffJobs[job.name]
end

local function sanitise(text, maxLength)
    text = tostring(text or ''):gsub('[%c]', ' ')

    return text:sub(1, maxLength)
end

local function canAct(source)
    local now = os.time()

    if now - (actionCooldowns[source] or 0) < 2 then
        return false
    end

    actionCooldowns[source] = now

    return true
end

RegisterNetEvent('whellco_report_dashboard:open', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isStaff(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not authorised to use the report dashboard.', 'error')
        return
    end

    TriggerClientEvent('whellco_report_dashboard:open', source)
end)

RegisterNetEvent('whellco_report_dashboard:refresh', function(page)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isStaff(Player) then
        return
    end

    page = math.max(1, tonumber(page) or 1)
    local offset = (page - 1) * Config.ReportsPerPage

    local reports = MySQL.query.await(
        [[SELECT id, report_type, title, description, reporter_citizenid, target_citizenid,
                 coords_x, coords_y, coords_z, status, claimed_by, created_at
          FROM whellco_player_reports
          WHERE status IN ('open', 'claimed')
          ORDER BY created_at ASC
          LIMIT ? OFFSET ?]],
        {
            Config.ReportsPerPage,
            offset
        }
    )

    local count = MySQL.scalar.await(
        [[SELECT COUNT(*)
          FROM whellco_player_reports
          WHERE status IN ('open', 'claimed')]]
    )

    TriggerClientEvent('whellco_report_dashboard:refresh', source, {
        reports = reports,
        page = page,
        totalPages = math.max(1, math.ceil(count / Config.ReportsPerPage)),
        openCount = count
    })
end)

RegisterNetEvent('whellco_report_dashboard:action', function(action, reportId, note)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isStaff(Player) or not canAct(source) then
        return
    end

    reportId = tonumber(reportId) or 0
    note = sanitise(note, Config.MaxNoteLength)

    if action == 'claim' then
        local updated = MySQL.update.await(
            [[UPDATE whellco_player_reports
              SET status = 'claimed', claimed_by = ?
              WHERE id = ? AND status = 'open']],
            {
                Player.PlayerData.citizenid,
                reportId
            }
        )

        TriggerClientEvent('QBCore:Notify', source, updated and updated > 0 and ('Claimed report #%d.'):format(reportId) or 'Report is not available to claim.', updated and updated > 0 and 'success' or 'error')

    elseif action == 'close' then
        local updated = MySQL.update.await(
            [[UPDATE whellco_player_reports
              SET status = 'closed', closed_by = ?, resolution_note = ?
              WHERE id = ? AND status IN ('open', 'claimed')]],
            {
                Player.PlayerData.citizenid,
                note,
                reportId
            }
        )

        TriggerClientEvent('QBCore:Notify', source, updated and updated > 0 and ('Closed report #%d.'):format(reportId) or 'Report could not be closed.', updated and updated > 0 and 'success' or 'error')

    elseif action == 'goto' then
        local report = MySQL.single.await(
            [[SELECT coords_x, coords_y, coords_z
              FROM whellco_player_reports
              WHERE id = ? AND status IN ('open', 'claimed')]],
            {
                reportId
            }
        )

        if report then
            TriggerClientEvent('whellco_report_dashboard:goto', source, vector3(report.coords_x, report.coords_y, report.coords_z))
        end
    end
end)

RegisterCommand(Config.DashboardCommand, function(source)
    TriggerEvent('whellco_report_dashboard:open')
end, false)