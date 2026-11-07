local function getIdentifier(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')

    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'steam')
    end

    return identifier
end

local function getOrCreateAccount(identifier)
    local account = MySQL.single.await(
        [[
            SELECT id, balance
            FROM whellco_bank_accounts
            WHERE character_id = ?
            LIMIT 1
        ]],
        { identifier }
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
        { identifier, Config.StartingBalance }
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
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local account = getOrCreateAccount(identifier)

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
    local identifier = getIdentifier(source)

    if not identifier or not amount or amount <= 0 then
        return
    end

    local account = getOrCreateAccount(identifier)

    MySQL.query.await(
        [[
            UPDATE whellco_bank_accounts
            SET balance = balance + ?
            WHERE id = ?
        ]],
        { amount, account.id }
    )

    local newBalance = account.balance + amount

    recordTransaction(account.id, 'deposit', amount, newBalance)

    TriggerClientEvent('whellco_banking:notify', source, ('Deposited £%s.'):format(amount))
    sendMenu(source)
end)

RegisterNetEvent('whellco_banking:withdraw', function(amount)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier or not amount or amount <= 0 then
        return
    end

    local account = getOrCreateAccount(identifier)

    if account.balance < amount then
        TriggerClientEvent('whellco_banking:notify', source, 'Insufficient funds.')
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

    local newBalance = account.balance - amount

    recordTransaction(account.id, 'withdrawal', amount, newBalance)

    TriggerClientEvent('whellco_banking:notify', source, ('Withdrew £%s.'):format(amount))
    sendMenu(source)
end)

RegisterNetEvent('whellco_banking:transfer', function(targetId, amount)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier or not targetId or not amount or amount <= 0 then
        return
    end

    local target = GetPlayerFromServerId(targetId)

    if target == 0 then
        return
    end

    local targetIdentifier = getIdentifier(target)

    if not targetIdentifier then
        return
    end

    local senderAccount = getOrCreateAccount(identifier)
    local targetAccount = getOrCreateAccount(targetIdentifier)

    if senderAccount.balance < amount then
        TriggerClientEvent('whellco_banking:notify', source, 'Insufficient funds.')
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

    local senderBalance = senderAccount.balance - amount
    local targetBalance = targetAccount.balance + amount

    recordTransaction(senderAccount.id, 'transfer', amount, senderBalance)
    recordTransaction(targetAccount.id, 'transfer', amount, targetBalance)

    TriggerClientEvent('whellco_banking:notify', source, ('Sent £%s.'):format(amount))
    TriggerClientEvent('whellco_banking:notify', target, ('Received £%s.'):format(amount))
    sendMenu(source)
end)
