local function getIdentifier(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')

    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'steam')
    end

    return identifier
end

local function searchCharacters(query)
    local like = ('%%%s%%'):format(tostring(query or ''))

    return MySQL.query.await(
        [[
            SELECT
                c.id,
                c.identifier,
                c.first_name,
                c.last_name,
                c.date_of_birth,
                c.gender,
                p.cash,
                p.bank,
                p.xp,
                p.level
            FROM whellco_characters c
            LEFT JOIN whellco_players p ON p.character_id = c.id
            WHERE c.first_name LIKE ?
               OR c.last_name LIKE ?
               OR c.identifier LIKE ?
            ORDER BY c.created_at DESC
            LIMIT ?
        ]],
        { like, like, like, Config.MaxResults }
    ) or {}
end

local function sendResults(source, results)
    TriggerClientEvent('whellco_admin:openPanel', source, {
        results = results
    })
end

RegisterNetEvent('whellco_admin:openPanel', function()
    local source = source

    local results = searchCharacters('')

    sendResults(source, results)
end)

RegisterNetEvent('whellco_admin:closePanel', function()
    local source = source

    TriggerClientEvent('whellco_admin:closePanel', source)
end)

RegisterNetEvent('whellco_admin:searchPlayers', function(query)
    local source = source

    local results = searchCharacters(query)

    sendResults(source, results)
end)

RegisterNetEvent('whellco_admin:giveMoney', function(data)
    local source = source
    local characterId = tonumber(data.characterId)
    local amount = tonumber(data.amount)
    local accountType = tostring(data.accountType or 'cash')

    if not characterId or not amount or amount <= 0 then
        return
    end

    if accountType ~= 'cash' and accountType ~= 'bank' then
        return
    end

    local column = accountType == 'cash' and 'cash' or 'bank'

    MySQL.update.await(
        ('UPDATE whellco_players SET %s = %s + ? WHERE character_id = ?'):format(column, column),
        { amount, characterId }
    )

    TriggerClientEvent('whellco_admin:notify', source, ('Added %s%d to %s.'):format(Config.Currency, amount, accountType))
end)

RegisterNetEvent('whellco_admin:removeMoney', function(data)
    local source = source
    local characterId = tonumber(data.characterId)
    local amount = tonumber(data.amount)
    local accountType = tostring(data.accountType or 'cash')

    if not characterId or not amount or amount <= 0 then
        return
    end

    if accountType ~= 'cash' and accountType ~= 'bank' then
        return
    end

    local column = accountType == 'cash' and 'cash' or 'bank'

    MySQL.update.await(
        ('UPDATE whellco_players SET %s = GREATEST(0, %s - ?) WHERE character_id = ?'):format(column, column),
        { amount, characterId }
    )

    TriggerClientEvent('whellco_admin:notify', source, ('Removed %s%d from %s.'):format(Config.Currency, amount, accountType))
end)
