local QBCore = exports['qb-core']:GetCoreObject()

local reportCooldowns = {}

local function isStaff(Player)
    local job = Player.PlayerData.job

    return job and Config.StaffJobs[job.name]
end

local function sanitise(text, maxLength)
    text = tostring(text or ''):gsub('[%c]', ' ')

    return text:sub(1, maxLength)
end

local function sendDiscordReport(report)
    if not Config.WebhookURL or Config.WebhookURL == '' then
        return
    end

    local payload = {
        username = Config.WebhookName,
        embeds = {
            {
                title = ('New Report: %s'):format(report.typeLabel),
                color = 15158332,
                fields = {
                    {
                        name = 'Reporter',
                        value = ('%s (`%s`)'):format(report.reporterName, report.reporterCitizenid),
                        inline = true
                    },
                    {
                        name = 'Reported Player',
                        value = report.targetSource and ('%s (`%s`)'):format(report.targetName, report.targetCitizenid) or 'Not specified',
                        inline = true
                    },
                    {
                        name = 'Title',
                        value = report.title
                    },
                    {
                        name = 'Description',
                        value = report.description
                    },
                    {
                        name = 'Location',
                        value = ('%.2f, %.2f, %.2f'):format(report.coords.x, report.coords.y, report.coords.z),
                        inline = true
                    },
                    {
                        name = 'Server Time',
                        value = os.date('%Y-%m-%d %H:%M:%S', report.createdAt),
                        inline = true
                    }
                },
                footer = {
                    text = 'Wheller Player Reports'
                }
            }
        }
    }

    PerformHttpRequest(Config.WebhookURL, function(status)
        if status ~= 200 and status ~= 204 then
            print(('^1[whellco_player_reports] Discord webhook failed with status %s^0'):format(status))
        end
    end, 'POST', json.encode(payload), {
        ['Content-Type'] = 'application/json'
    })
end

RegisterNetEvent('whellco_player_reports:submit', function(data)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local now = os.time()

    if now - (reportCooldowns[source] or 0) < Config.ReportCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before submitting another report.', 'error')
        return
    end

    local reportType = tostring(data.reportType or '')
    local typeLabel = Config.ReportTypes[reportType]

    if not typeLabel then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid report type.', 'error')
        return
    end

    local title = sanitise(data.title, Config.MaxTitleLength)
    local description = sanitise(data.description, Config.MaxDescriptionLength)

    if #title < 3 or #description < 10 then
        TriggerClientEvent('QBCore:Notify', source, 'Please provide a clear title and description.', 'error')
        return
    end

    local targetSource = tonumber(data.targetSource) or 0
    local Target = targetSource > 0 and QBCore.Functions.GetPlayer(targetSource) or nil
    local coords = GetEntityCoords(GetPlayerPed(source))

    local report = {
        reporterCitizenid = Player.PlayerData.citizenid,
        reporterName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        targetCitizenid = Target and Target.PlayerData.citizenid or nil,
        targetName = Target and (Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname) or nil,
        targetSource = Target and Target.PlayerData.source or nil,
        type = reportType,
        typeLabel = typeLabel,
        title = title,
        description = description,
        coords = coords,
        createdAt = now
    }

    MySQL.query.await(
        [[INSERT INTO whellco_player_reports
            (reporter_citizenid, target_citizenid, report_type, title, description, coords_x, coords_y, coords_z, status)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'open')]],
        {
            report.reporterCitizenid,
            report.targetCitizenid,
            report.type,
            report.title,
            report.description,
            coords.x,
            coords.y,
            coords.z
        }
    )

    reportCooldowns[source] = now

    sendDiscordReport(report)

    local players = QBCore.Functions.GetQBPlayers()

    for _, staff in pairs(players) do
        if isStaff(staff) then
            TriggerClientEvent('whellco_player_reports:new', staff.PlayerData.source, report)
        end
    end

    TriggerClientEvent('QBCore:Notify', source, 'Report submitted. Staff have been notified.', 'success')
end)

RegisterCommand(Config.ReportCommand, function(source)
    TriggerClientEvent('whellco_player_reports:open', source)
end, false)