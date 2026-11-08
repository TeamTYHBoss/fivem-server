local QBCore = exports['qb-core']:GetCoreObject()

local function isStaff(Player)
    local job = Player.PlayerData.job

    return job and Config.StaffJobs[job.name]
end

local function sanitise(text, maxLength)
    text = tostring(text or ''):gsub('[%c]', ' ')

    return text:sub(1, maxLength)
end

local function sendReportList(source, reports, page, totalPages)
    local lines = {
        ('Open reports - page %d/%d'):format(page, totalPages)
    }

    for _, report in ipairs(reports) do
        table.insert(lines, ('#%d [%s] %s - by %s'):format(
            report.id,
            report.report_type,
            report.title,
            report.reporter_citizenid
        ))
    end

    TriggerClientEvent('chat:addMessage', source, {
        color = {255, 170, 0},
        args = {'Report Management', table.concat(lines, '\n')}
    })
end

RegisterCommand('reports', function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isStaff(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not authorised to manage reports.', 'error')
        return
    end

    local page = math.max(1, tonumber(args[1]) or 1)
    local offset = (page - 1) * Config.ReportsPerPage

    local reports = MySQL.query.await(
        [[SELECT id, report_type, title, reporter_citizenid, created_at
          FROM whellco_player_reports
          WHERE status = 'open'
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
          WHERE status = 'open']]
    )

    local totalPages = math.max(1, math.ceil(count / Config.ReportsPerPage))

    if #reports == 0 then
        TriggerClientEvent('QBCore:Notify', source, 'There are no open reports.', 'primary')
        return
    end

    sendReportList(source, reports, page, totalPages)
end, false)

RegisterCommand('reportview', function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    local reportId = tonumber(args[1])

    if not Player or not isStaff(Player) or not reportId then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /reportview [report_id]', 'error')
        return
    end

    local report = MySQL.single.await(
        [[SELECT id, report_type, title, description, reporter_citizenid, target_citizenid,
                 coords_x, coords_y, coords_z, status, created_at
          FROM whellco_player_reports
          WHERE id = ?]],
        {
            reportId
        }
    )

    if not report then
        TriggerClientEvent('QBCore:Notify', source, 'Report not found.', 'error')
        return
    end

    TriggerClientEvent('chat:addMessage', source, {
        color = {255, 170, 0},
        args = {
            'Report Details',
            ('#%d [%s]\nTitle: %s\nDescription: %s\nReporter: %s\nTarget: %s\nLocation: %.2f, %.2f, %.2f\nStatus: %s'):format(
                report.id,
                report.report_type,
                report.title,
                report.description,
                report.reporter_citizenid,
                report.target_citizenid or 'None',
                report.coords_x,
                report.coords_y,
                report.coords_z,
                report.status
            )
        }
    })
end, false)

RegisterCommand('reportclaim', function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    local reportId = tonumber(args[1])

    if not Player or not isStaff(Player) or not reportId then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /reportclaim [report_id]', 'error')
        return
    end

    local updated = MySQL.update.await(
        [[UPDATE whellco_player_reports
          SET status = 'claimed', claimed_by = ?
          WHERE id = ? AND status = 'open']],
        {
            Player.PlayerData.citizenid,
            reportId
        }
    )

    if updated and updated > 0 then
        TriggerClientEvent('QBCore:Notify', source, ('Claimed report #%d.'):format(reportId), 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, 'Report is not available to claim.', 'error')
    end
end, false)

RegisterCommand('reportclose', function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    local reportId = tonumber(args[1])
    local note = sanitise(table.concat(args, ' ', 2), Config.MaxNoteLength)

    if not Player or not isStaff(Player) or not reportId then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /reportclose [report_id] [note]', 'error')
        return
    end

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

    if updated and updated > 0 then
        TriggerClientEvent('QBCore:Notify', source, ('Closed report #%d.'):format(reportId), 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, 'Report could not be closed.', 'error')
    end
end, false)

RegisterCommand('reportreopen', function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    local reportId = tonumber(args[1])

    if not Player or not isStaff(Player) or not reportId then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /reportreopen [report_id]', 'error')
        return
    end

    local updated = MySQL.update.await(
        [[UPDATE whellco_player_reports
          SET status = 'open', claimed_by = NULL, closed_by = NULL, resolution_note = NULL
          WHERE id = ? AND status = 'closed']],
        {
            reportId
        }
    )

    if updated and updated > 0 then
        TriggerClientEvent('QBCore:Notify', source, ('Reopened report #%d.'):format(reportId), 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, 'Only closed reports can be reopened.', 'error')
    end
end, false)

RegisterCommand('reporthelp', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isStaff(Player) then
        return
    end

    TriggerClientEvent('QBCore:Notify', source, 'Report commands: /reports [page], /reportview [id], /reportclaim [id], /reportclose [id] [note], /reportreopen [id].', 'primary')
end, false)