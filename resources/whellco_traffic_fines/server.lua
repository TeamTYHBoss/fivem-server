local QBCore = exports['qb-core']:GetCoreObject()

local ticketCooldowns = {}

local function isPolice(Player)
    local job = Player.PlayerData.job

    return job and job.name == Config.PoliceJob
end

local function getPoints(citizenid)
    local total = MySQL.scalar.await(
        [[
            SELECT COALESCE(SUM(points), 0)
            FROM whellco_traffic_fines
            WHERE citizenid = ?
              AND status = 'unpaid'
        ]],
        { citizenid }
    )

    return tonumber(total) or 0
end

RegisterNetEvent('whellco_traffic_fines:issue', function(targetSource, fineType, reason)
    local source = source
    local Officer = QBCore.Functions.GetPlayer(source)
    local Target = QBCore.Functions.GetPlayer(tonumber(targetSource) or 0)
    local fine = Config.Fines[fineType]

    if not Officer or not Target or not fine then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid target or fine type.', 'error')
        return
    end

    if not isPolice(Officer) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not authorised to issue fines.', 'error')
        return
    end

    local now = os.time()

    if now - (ticketCooldowns[source] or 0) < Config.TicketCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before issuing another ticket.', 'error')
        return
    end

    local amount = fine.amount

    if amount > Config.MaxFineAmount then
        amount = Config.MaxFineAmount
    end

    MySQL.query.await(
        [[
            INSERT INTO whellco_traffic_fines
                (citizenid, officer_citizenid, fine_type, amount, points, reason, status)
            VALUES (?, ?, ?, ?, ?, ?, 'unpaid')
        ]],
        {
            Target.PlayerData.citizenid,
            Officer.PlayerData.citizenid,
            fineType,
            amount,
            fine.points,
            reason or fine.label
        }
    )

    ticketCooldowns[source] = now

    TriggerClientEvent('whellco_traffic_fines:ticketIssued', Target.PlayerData.source, {
        fineType = fineType,
        label = fine.label,
        amount = amount,
        points = fine.points,
        reason = reason or fine.label
    })

    TriggerClientEvent('QBCore:Notify', source, ('Issued %s for %s%d.'):format(fine.label, Config.CurrencySymbol, amount), 'success')
end)

RegisterNetEvent('whellco_traffic_fines:pay', function(fineId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local fine = MySQL.single.await(
        [[
            SELECT id, citizenid, amount, status
            FROM whellco_traffic_fines
            WHERE id = ?
        ]],
        { tonumber(fineId) or 0 }
    )

    if not fine or fine.citizenid ~= Player.PlayerData.citizenid then
        TriggerClientEvent('QBCore:Notify', source, 'Fine not found.', 'error')
        return
    end

    if fine.status ~= 'unpaid' then
        TriggerClientEvent('QBCore:Notify', source, 'This fine is already paid.', 'error')
        return
    end

    if Player.Functions.GetMoney('bank') < fine.amount then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough money in your bank account.', 'error')
        return
    end

    Player.Functions.RemoveMoney('bank', fine.amount, ('Traffic fine payment: %d'):format(fine.id))

    MySQL.update.await(
        [[
            UPDATE whellco_traffic_fines
            SET status = 'paid',
                paid_at = CURRENT_TIMESTAMP
            WHERE id = ?
        ]],
        { fine.id }
    )

    TriggerClientEvent('QBCore:Notify', source, ('Paid fine #%d for %s%d.'):format(fine.id, Config.CurrencySymbol, fine.amount), 'success')
end)

RegisterCommand('fine', function(source, args)
    local targetSource = args[1]
    local fineType = args[2]
    local reason = table.concat(args, ' ', 3)

    if not targetSource or not fineType then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /fine [player_id] [fine_type] [reason]', 'error')
        return
    end

    TriggerEvent('whellco_traffic_fines:issue', targetSource, fineType, reason)
end, false)

RegisterCommand('payfine', function(source, args)
    local fineId = args[1]

    if not fineId then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /payfine [fine_id]', 'error')
        return
    end

    TriggerEvent('whellco_traffic_fines:pay', fineId)
end, false)

RegisterCommand('myfines', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local fines = MySQL.query.await(
        [[
            SELECT id, fine_type, amount, points, status
            FROM whellco_traffic_fines
            WHERE citizenid = ?
            ORDER BY created_at DESC
            LIMIT 10
        ]],
        { Player.PlayerData.citizenid }
    )

    if not fines or #fines == 0 then
        TriggerClientEvent('QBCore:Notify', source, 'You have no fines.', 'primary')
        return
    end

    local output = {}

    for _, fine in ipairs(fines) do
        output[#output + 1] = ('#%d %s $%d %dpts %s'):format(
            fine.id,
            fine.fine_type,
            fine.amount,
            fine.points,
            fine.status
        )
    end

    TriggerClientEvent('QBCore:Notify', source, table.concat(output, ' | '), 'primary')
end, false)

RegisterCommand('licensepoints', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local points = getPoints(Player.PlayerData.citizenid)

    TriggerClientEvent('QBCore:Notify', source, ('You have %d unpaid license point(s).'):format(points), 'primary')
end, false)