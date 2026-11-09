local QBCore = exports['qb-core']:GetCoreObject()
local MySQL = exports.oxmysql

Computer = {
    QBCore = QBCore,
    MySQL = MySQL,
    RecoveryStates = {
        PENDING = 'pending',
        RECOVERY = 'recovery',
        RESOLVED = 'resolved'
    },
    Cooldowns = {
        bank = Utils.CreateCooldown(1000),
        shop = Utils.CreateCooldown(1000),
        marketplace = Utils.CreateCooldown(1000),
        social = Utils.CreateCooldown(1000),
        notifications = Utils.CreateCooldown(1000)
    }
}

function Computer.Notify(source, message, kind)
    Utils.Notify(source, message, kind)
end

function Computer.GetPlayer(source)
    return Utils.GetPlayer(source)
end

AddEventHandler('playerDropped', function()
    for _, cooldown in pairs(Computer.Cooldowns) do
        cooldown.Clear(source)
    end
end)

CreateThread(function()
    Wait(5000)

    MySQL.update(
        [[UPDATE whellco_computer_transfers
          SET status = ?
          WHERE status = ? AND created_at < NOW() - INTERVAL 5 MINUTE]],
        {
            Computer.RecoveryStates.RECOVERY,
            Computer.RecoveryStates.PENDING
        },
        function(affectedRows)
            if affectedRows and affectedRows > 0 then
                print(('[whellco_computer] Marked %d stale transfer(s) for recovery.'):format(affectedRows))
            end
        end
    )
end)

QBCore.Commands.Add('computerrecovery', 'List unresolved computer recovery records', {}, false, function(source)
    local Player = Computer.GetPlayer(source)

    if not Player then
        return
    end

    MySQL.query(
        [[SELECT id, request_id, sender, recipient, amount, status, created_at
          FROM whellco_computer_transfers
          WHERE status = ?
          ORDER BY id DESC
          LIMIT 50]],
        { Computer.RecoveryStates.RECOVERY },
        function(records)
            if not records or #records == 0 then
                Computer.Notify(source, 'No unresolved recovery records.', 'primary')
                return
            end

            for _, record in ipairs(records) do
                Computer.Notify(
                    source,
                    ('Recovery #%d | Transfer %s | %s to %s | %s | %s | Review payment and manually reconcile.'):format(
                        record.id,
                        record.request_id,
                        record.sender,
                        record.recipient,
                        Utils.FormatMoney(record.amount),
                        record.created_at
                    ),
                    'error'
                )
            end
        end
    )
end, 'admin')

QBCore.Commands.Add('computerresolve', 'Resolve a computer recovery record', {
    { name = 'id', help = 'Transfer record ID' }
}, true, function(source, args)
    local Player = Computer.GetPlayer(source)
    local recordId = Utils.ValidatePositiveInteger(args[1], 1)

    if not Player or not recordId then
        return
    end

    MySQL.update(
        'UPDATE whellco_computer_transfers SET status = ? WHERE id = ? AND status = ?',
        {
            Computer.RecoveryStates.RESOLVED,
            recordId,
            Computer.RecoveryStates.RECOVERY
        },
        function(affectedRows)
            if affectedRows and affectedRows > 0 then
                Computer.Notify(source, ('Resolved recovery record #%d.'):format(recordId), 'success')
            else
                Computer.Notify(source, 'Recovery record not found or already resolved.', 'error')
            end
        end
    )
end, 'admin')
