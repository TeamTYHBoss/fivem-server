local QBCore = exports['qb-core']:GetCoreObject()

local function getAccount(Player, accountType)
    local accounts = MySQL.single.await(
        [[
            SELECT id, balance
            FROM whellco_bank_accounts
            WHERE citizenid = ?
              AND account_type = ?
        ]],
        { Player.PlayerData.citizenid, accountType }
    )

    if accounts then
        return accounts
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_bank_accounts
                (citizenid, account_type, balance)
            VALUES (?, ?, 0)
        ]],
        { Player.PlayerData.citizenid, accountType }
    )

    return {
        id = nil,
        balance = 0
    }
end

local function recordTransaction(accountId, transactionType, amount, balance, details)
    MySQL.insert.await(
        [[
            INSERT INTO whellco_bank_transactions
                (account_id, transaction_type, amount, balance_after, details)
            VALUES (?, ?, ?, ?, ?)
        ]],
        { accountId, transactionType, amount, balance, details or '' }
    )
end

local function validateAmount(amount)
    amount = math.floor(tonumber(amount) or 0)

    if amount <= 0 or amount > Config.MaxTransactionAmount then
        return nil, 'Invalid transaction amount.'
    end

    return amount
end

RegisterNetEvent('whellco_banking_atm:openAccount', function(accountType)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not Config.AllowedAccounts[accountType] then
        return
    end

    local account = getAccount(Player, accountType)
    local transactions = MySQL.query.await(
        [[
            SELECT transaction_type, amount, balance_after, details, created_at
            FROM whellco_bank_transactions
            WHERE account_id = ?
            ORDER BY created_at DESC
            LIMIT 25
        ]],
        { account.id }
    ) or {}

    TriggerClientEvent('whellco_banking_atm:openAccount', source, {
        accountType = accountType,
        balance = account.balance,
        cash = Player.Functions.GetMoney('cash'),
        transactions = transactions
    })
end)

RegisterNetEvent('whellco_banking_atm:deposit', function(accountType, amount)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not Config.AllowedAccounts[accountType] then
        return
    end

    amount, error = validateAmount(amount)

    if not amount then
        TriggerClientEvent('QBCore:Notify', source, error, 'error')
        return
    end

    if Player.Functions.GetMoney('cash') < amount then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough cash.', 'error')
        return
    end

    local account = getAccount(Player, accountType)
    local newBalance = account.balance + amount

    Player.Functions.RemoveMoney('cash', amount, 'Bank deposit')

    MySQL.update.await(
        [[
            UPDATE whellco_bank_accounts
            SET balance = ?
            WHERE citizenid = ?
              AND account_type = ?
        ]],
        { newBalance, Player.PlayerData.citizenid, accountType }
    )

    recordTransaction(account.id, 'deposit', amount, newBalance, 'Cash deposit')

    TriggerClientEvent('QBCore:Notify', source, ('Deposited %s%d.'):format(Config.CurrencySymbol, amount), 'success')
    TriggerEvent('whellco_banking_atm:openAccount', accountType)
end)

RegisterNetEvent('whellco_banking_atm:withdraw', function(accountType, amount)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not Config.AllowedAccounts[accountType] then
        return
    end

    amount, error = validateAmount(amount)

    if not amount then
        TriggerClientEvent('QBCore:Notify', source, error, 'error')
        return
    end

    if amount > Config.ATMWithdrawalLimit then
        TriggerClientEvent('QBCore:Notify', source, ('ATM withdrawal limit is %s%d.'):format(Config.CurrencySymbol, Config.ATMWithdrawalLimit), 'error')
        return
    end

    local account = getAccount(Player, accountType)

    if account.balance < amount then
        TriggerClientEvent('QBCore:Notify', source, 'Insufficient account balance.', 'error')
        return
    end

    local newBalance = account.balance - amount

    Player.Functions.AddMoney('cash', amount, 'Bank withdrawal')

    MySQL.update.await(
        [[
            UPDATE whellco_bank_accounts
            SET balance = ?
            WHERE citizenid = ?
              AND account_type = ?
        ]],
        { newBalance, Player.PlayerData.citizenid, accountType }
    )

    recordTransaction(account.id, 'withdrawal', amount, newBalance, 'ATM withdrawal')

    TriggerClientEvent('QBCore:Notify', source, ('Withdrew %s%d.'):format(Config.CurrencySymbol, amount), 'success')
    TriggerEvent('whellco_banking_atm:openAccount', accountType)
end)

RegisterNetEvent('whellco_banking_atm:transfer', function(accountType, targetCitizenId, amount)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not Config.AllowedAccounts[accountType] then
        return
    end

    amount, error = validateAmount(amount)

    if not amount then
        TriggerClientEvent('QBCore:Notify', source, error, 'error')
        return
    end

    local fee = math.floor(amount * (Config.TransferFeePercent / 100))
    local total = amount + fee
    local account = getAccount(Player, accountType)

    if account.balance < total then
        TriggerClientEvent('QBCore:Notify', source, 'Insufficient account balance.', 'error')
        return
    end

    local target = MySQL.single.await(
        [[
            SELECT citizenid
            FROM players
            WHERE citizenid = ?
        ]],
        { targetCitizenId }
    )

    if not target then
        TriggerClientEvent('QBCore:Notify', source, 'Target account not found.', 'error')
        return
    end

    local targetAccount = getAccount({ PlayerData = { citizenid = targetCitizenId } }, accountType)
    local newSenderBalance = account.balance - total
    local newTargetBalance = targetAccount.balance + amount

    MySQL.update.await(
        [[
            UPDATE whellco_bank_accounts
            SET balance = ?
            WHERE citizenid = ?
              AND account_type = ?
        ]],
        { newSenderBalance, Player.PlayerData.citizenid, accountType }
    )

    MySQL.update.await(
        [[
            UPDATE whellco_bank_accounts
            SET balance = ?
            WHERE citizenid = ?
              AND account_type = ?
        ]],
        { newTargetBalance, targetCitizenId, accountType }
    )

    recordTransaction(account.id, 'transfer_out', total, newSenderBalance, ('Transfer to %s'):format(targetCitizenId))
    recordTransaction(targetAccount.id, 'transfer_in', amount, newTargetBalance, ('Transfer from %s'):format(Player.PlayerData.citizenid))

    TriggerClientEvent('QBCore:Notify', source, ('Transferred %s%d.'):format(Config.CurrencySymbol, amount), 'success')
end)

RegisterCommand('bank', function(source)
    if source > 0 then
        local Player = QBCore.Functions.GetPlayer(source)

        if Player then
            TriggerEvent('whellco_banking_atm:openAccount', 'checking')
        end
    end
end, false)

RegisterCommand('atm', function(source)
    if source > 0 then
        local Player = QBCore.Functions.GetPlayer(source)

        if Player then
            TriggerEvent('whellco_banking_atm:openAccount', 'checking')
        end
    end
end, false)