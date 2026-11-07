local function getIdentifier(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')

    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'steam')
    end

    return identifier
end

local function getBalance(identifier)
    local account = MySQL.single.await(
        [[
            SELECT balance
            FROM whellco_bank_accounts
            WHERE character_id = ?
            LIMIT 1
        ]],
        { identifier }
    )

    return account and account.balance or 0
end

local function recordReceipt(identifier, category, description, amount)
    MySQL.insert.await(
        [[
            INSERT INTO whellco_economy_receipts
                (character_id, category, description, amount)
            VALUES (?, ?, ?, ?)
        ]],
        { identifier, category, description, amount }
    )
end

local function sendMenu(source)
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local sections = {}

    for id, label in pairs(Config.EconomySections) do
        sections[#sections + 1] = {
            id = id,
            label = label
        }
    end

    local receipts = MySQL.query.await(
        [[
            SELECT id, category, description, amount, created_at
            FROM whellco_economy_receipts
            WHERE character_id = ?
            ORDER BY created_at DESC
            LIMIT 25
        ]],
        { identifier }
    ) or {}

    TriggerClientEvent('whellco_economy_hub:openMenu', source, {
        balance = getBalance(identifier),
        sections = sections,
        receipts = receipts
    })
end

RegisterNetEvent('whellco_economy_hub:openMenu', function()
    sendMenu(source)
end)

RegisterNetEvent('whellco_economy_hub:closeMenu', function()
    TriggerClientEvent('whellco_economy_hub:closeMenu', source)
end)

RegisterNetEvent('whellco_economy_hub:openSection', function(section)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    if not Config.EconomySections[section] then
        return
    end

    TriggerClientEvent('whellco_economy_hub:notify', source, ('Opening %s.'):format(Config.EconomySections[section]))
end)

AddEventHandler('whellco_economy_hub:recordReceipt', function(identifier, category, description, amount)
    recordReceipt(identifier, category, description, amount)
end)
