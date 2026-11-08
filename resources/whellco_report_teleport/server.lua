local QBCore = exports['qb-core']:GetCoreObject()

local teleportCooldowns = {}

local function isStaff(Player)
    local job = Player.PlayerData.job

    return job and Config.StaffJobs[job.name]
end

RegisterNetEvent('whellco_report_teleport:go', function(reportId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isStaff(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not authorised to teleport to reports.', 'error')
        return
    end

    local now = os.time()

    if now - (teleportCooldowns[source] or 0) < Config.TeleportCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before teleporting again.', 'error')
        return
    end

    reportId = tonumber(reportId) or 0

    local report = MySQL.single.await(
        [[SELECT id, coords_x, coords_y, coords_z, status
          FROM whellco_player_reports
          WHERE id = ? AND status IN ('open', 'claimed')]],
        {
            reportId
        }
    )

    if not report then
        TriggerClientEvent('QBCore:Notify', source, 'Open report not found.', 'error')
        return
    end

    teleportCooldowns[source] = now

    TriggerClientEvent('whellco_report_teleport:go', source, {
        reportId = report.id,
        coords = vector3(report.coords_x, report.coords_y, report.coords_z)
    })

    MySQL.query.await(
        [[INSERT INTO whellco_report_teleports
            (staff_citizenid, report_id)
          VALUES (?, ?)]],
        {
            Player.PlayerData.citizenid,
            report.id
        }
    )
end)

RegisterCommand(Config.TeleportCommand, function(source, args)
    local reportId = args[1]

    if not reportId then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /gotoreport [report_id]', 'error')
        return
    end

    TriggerEvent('whellco_report_teleport:go', reportId)
end, false)