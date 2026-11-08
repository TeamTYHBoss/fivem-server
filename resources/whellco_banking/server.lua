local QBCore = exports['qb-core']:GetCoreObject()

local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

local function getOrCreateAccount(citizenId)
    local account = MySQL.single.await(
        [[
            SELECT id, balance
            FROM whellco_bank_accounts
            WHERE character_id = ?
            LIMIT 1
        ]],
        { citizenId }
    )

    if account then
        return account
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_bank_accounts
                (character_id, balance)
            VALUES (?, ?)
        ]],
        { citizenId, Config.StartingBalance }
    )

    return {
        id = MySQL.lastInsertId,
        balance = Config.StartingBalance
    }
end

local function recordTransaction(accountId, transactionType, amount, balanceAfter)
    MySQL.insert.await(
        [[
            INSERT INTO whellco_bank_transactions
                (account_id, transaction_type, amount, balance_after)
            VALUES (?, ?, ?, ?)
        ]],
        { accountId, transactionType, amount, balanceAfter }
    )
end

local function sendMenu(source)
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    local account = getOrCreateAccount(Player.PlayerData.citizenid)

    local transactions = MySQL.query.await(
        [[
            SELECT id, transaction_type, amount, balance_after, created_at
            FROM whellco_bank_transactions
            WHERE account_id = ?
            ORDER BY created_at DESC
            LIMIT 25
        ]],
        { account.id }
    ) or {}

    TriggerClientEvent('whellco_banking:openMenu', source, {
        balance = account.balance,
        transactions = transactions
    })
end

RegisterNetEvent('whellco_banking:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_banking:closeMenu', function()
    TriggerClientEvent('whellco_banking:closeMenu', source)
end)

RegisterNetEvent('whellco_banking:deposit', function(amount)
    local source = source
    local Player = getQbPlayer(source)

    amount = math.floor(tonumber(amount) or 0)

    if not Player or amount <= 0 then
        return
    end

    if Player.Functions.GetMoney('cash') < amount then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have enough cash.', 'error')
        return
    end

    if not Player.Functions.RemoveMoney('cash', amount, 'Bank deposit') then
        return
    end

    local account = getOrCreateAccount(Player.PlayerData.citizenid)

    MySQL.query.await(
        [[
            UPDATE whellco_bank_accounts
            SET balance = balance + ?
            WHERE id = ?
        ]],
        { amount, account.id }
    )

    recordTransaction(account.id, 'deposit', amount, account.balance + amount)

    TriggerClientEvent('QBCore:Notify', source, ('Deposited £%s.'):format(amount), 'success')
    sendMenu(source)
end)

RegisterNetEvent('whellco_banking:withdraw', function(amount)
    local source = source
    local Player = getQbPlayer(source)

    amount = math.floor(tonumber(amount) or 0)

    if not Player or amount <= 0 then
        return
    end

    local account = getOrCreateAccount(Player.PlayerData.citizenid)

    if account.balance < amount then
        TriggerClientEvent('QBCore:Notify', source, 'Insufficient funds.', 'error')
        return
    end

    MySQL.query.await(
        [[
            UPDATE whellco_bank_accounts
            SET balance = balance - ?
            WHERE id = ?
        ]],
        { amount, account.id }
    )

    if not Player.Functions.AddMoney('cash', amount, 'Bank withdrawal') then
        MySQL.query.await(
            [[
                UPDATE whellco_bank_accounts
                SET balance = balance + ?
                WHERE id = ?
            ]],
            { amount, account.id }
        )

        return
    end

    recordTransaction(account.id, 'withdrawal', amount, account.balance - amount)

    TriggerClientEvent('QBCore:Notify', source, ('Withdrew £%s.'):format(amount), 'success')
    sendMenu(source)
end)

RegisterNetEvent('whellco_banking:transfer', function(targetId, amount)
    local source = source
    local Player = getQbPlayer(source)

    amount = math.floor(tonumber(amount) or 0)

    if not Player or not targetId or amount <= 0 then
        return
    end

    local target = GetPlayerFromServerId(targetId)
    local TargetPlayer = target > 0 and getQbPlayer(target) or nil

    if not TargetPlayer then
        TriggerClientEvent('QBCore:Notify', source, 'That player is not online.', 'error')
        return
    end

    local senderAccount = getOrCreateAccount(Player.PlayerData.citizenid)
    local targetAccount = getOrCreateAccount(TargetPlayer.PlayerData.citizenid)

    if senderAccount.balance < amount then
        TriggerClientEvent('QBCore:Notify', source, 'Insufficient funds.', 'error')
        return
    end

    MySQL.transaction.await({
        {
            query = [[
                UPDATE whellco_bank_accounts
                SET balance = balance - ?
                WHERE id = ?
            ]],
            values = { amount, senderAccount.id }
        },
        {
            query = [[
                UPDATE whellco_bank_accounts
                SET balance = balance + ?
                WHERE id = ?
            ]],
            values = { amount, targetAccount.id }
        }
    })

    recordTransaction(senderAccount.id, 'transfer', amount, senderAccount.balance - amount)
    recordTransaction(targetAccount.id, 'transfer', amount, targetAccount.balance + amount)

    TriggerClientEvent('QBCore:Notify', source, ('Sent £%s.'):format(amount), 'success')
    TriggerClientEvent('QBCore:Notify', target, ('Received £%s.'):format(amount), 'success')

    sendMenu(source)
end)