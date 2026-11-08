local MAX_TRANSFER = 1000000

QBCore.Functions.CreateCallback('whellco_computer:getBankBalance', function(source, cb)
    local Player = Computer.GetPlayer(source)

    if not Player then
        cb(0)
        return
    end

    cb(Player.PlayerData.money.bank or 0)
end)

QBCore.Functions.CreateCallback('whellco_computer:transferMoney', function(source, cb, data)
    local Player = Computer.GetPlayer(source)
    local recipientId = data and data.recipientId
    local amount = data and data.amount

    if not Player or type(recipientId) ~= 'string' then
        cb(false, 'Invalid transfer request.')
        return
    end

    if Computer.Cooldown.IsOnCooldown(source) then
        cb(false, 'Please wait before making another transfer.')
        return
    end

    local transferAmount = Utils.ValidatePositiveInteger(amount, 1, MAX_TRANSFER)

    if not transferAmount then
        cb(false, 'Invalid transfer amount.')
        return
    end

    local recipient = Utils.GetPlayerByCitizenId(recipientId)

    if not recipient then
        cb(false, 'That player is not online.')
        return
    end

    if recipient.PlayerData.citizenid == Player.PlayerData.citizenid then
        cb(false, 'You cannot transfer money to yourself.')
        return
    end

    if (Player.PlayerData.money.bank or 0) < transferAmount then
        cb(false, 'You do not have enough money in your bank account.')
        return
    end

    Computer.Cooldown.SetCooldown(source)

    local requestId = ('%s-%d'):format(Player.PlayerData.citizenid, GetGameTimer())

    Computer.MySQL.insert(
        [[INSERT INTO whellco_computer_transfers
            (request_id, sender, recipient, amount, status)
          VALUES (?, ?, ?, ?, ?)]],
        {
            requestId,
            Player.PlayerData.citizenid,
            recipient.PlayerData.citizenid,
            transferAmount,
            Computer.RecoveryStates.PENDING
        },
        function(insertId)
            if not insertId then
                cb(false, 'Transfer could not be started.')
                return
            end

            local sender = Utils.GetPlayerByCitizenId(Player.PlayerData.citizenid)
            local receiver = Utils.GetPlayerByCitizenId(recipientId)

            if not sender or not receiver then
                Computer.MySQL.update(
                    'UPDATE whellco_computer_transfers SET status = ? WHERE id = ?',
                    { Computer.RecoveryStates.RECOVERY, insertId }
                )

                cb(false, 'Transfer could not be completed.')
                return
            end

            if not sender.Functions.RemoveMoney('bank', transferAmount, 'computer-transfer') then
                Computer.MySQL.update(
                    'UPDATE whellco_computer_transfers SET status = ? WHERE id = ?',
                    { Computer.RecoveryStates.RECOVERY, insertId }
                )

                cb(false, 'Transfer failed.')
                return
            end

            if not receiver.Functions.AddMoney('bank', transferAmount, 'computer-transfer') then
                sender.Functions.AddMoney('bank', transferAmount, 'computer-transfer-refund')

                Computer.MySQL.update(
                    'UPDATE whellco_computer_transfers SET status = ? WHERE id = ?',
                    { Computer.RecoveryStates.RECOVERY, insertId }
                )

                cb(false, 'Transfer failed and was refunded.')
                return
            end

            Computer.MySQL.update(
                'UPDATE whellco_computer_transfers SET status = ? WHERE id = ?',
                { 'completed', insertId }
            )

            cb(true, ('Sent %s.'):format(Utils.FormatMoney(transferAmount)))
        end
    )
end)

QBCore.Functions.CreateCallback('whellco_computer:getTransfers', function(source, cb)
    local Player = Computer.GetPlayer(source)

    if not Player then
        cb({})
        return
    end

    Computer.MySQL.query(
        [[SELECT id, request_id, sender, recipient, amount, status, created_at
          FROM whellco_computer_transfers
          WHERE sender = ? OR recipient = ?
          ORDER BY id DESC
          LIMIT 50]],
        {
            Player.PlayerData.citizenid,
            Player.PlayerData.citizenid
        },
        function(transfers)
            cb(transfers or {})
        end
    )
end)
