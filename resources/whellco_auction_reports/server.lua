local QBCore = exports['qb-core']:GetCoreObject()

local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

local function sendMenu(source)
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    local reports = MySQL.query.await(
        [[
            SELECT id, auction_id, reporter_id, reason, details, status, created_at
            FROM whellco_auction_reports
            WHERE reporter_id = ?
            ORDER BY created_at DESC
            LIMIT 25
        ]],
        { Player.PlayerData.citizenid }
    ) or {}

    TriggerClientEvent('whellco_auction_reports:openMenu', source, {
        reports = reports,
        reasons = Config.ReportReasons
    })
end

RegisterNetEvent('whellco_auction_reports:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_auction_reports:closeMenu', function()
    TriggerClientEvent('whellco_auction_reports:closeMenu', source)
end)

RegisterNetEvent('whellco_auction_reports:submitReport', function(auctionId, reason, details)
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    reason = tostring(reason or '')
    details = tostring(details or ''):sub(1, Config.MaxReportLength)

    local validReason = false

    for _, validReasonName in ipairs(Config.ReportReasons) do
        if validReasonName == reason then
            validReason = true
            break
        end
    end

    if not validReason then
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_auction_reports
                (auction_id, reporter_id, reason, details)
            VALUES (?, ?, ?, ?)
        ]],
        { auctionId, Player.PlayerData.citizenid, reason, details }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Auction report submitted.', 'success')

    sendMenu(source)
end)