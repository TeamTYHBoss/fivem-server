local activeCalls = {}

local function getIdentifier(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')

    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'steam')
    end

    return identifier
end

local function getOrCreatePhone(characterId)
    local phone = MySQL.single.await(
        'SELECT id, phone_number FROM whellco_phones WHERE character_id = ? LIMIT 1',
        { characterId }
    )

    if phone then
        return phone
    end

    local number = tostring(math.random(1000000000, 9999999999))

    MySQL.insert.await(
        'INSERT INTO whellco_phones (character_id, phone_number) VALUES (?, ?)',
        { characterId, number }
    )

    return {
        id = MySQL.insert.await(
            'SELECT id FROM whellco_phones WHERE character_id = ? LIMIT 1',
            { characterId }
        ),
        phone_number = number
    }
end

local function getContacts(characterId)
    return MySQL.query.await(
        [[
            SELECT c.id, c.contact_character_id, c.name, p.phone_number
            FROM whellco_contacts c
            LEFT JOIN whellco_phones p ON p.character_id = c.contact_character_id
            WHERE c.owner_character_id = ?
            ORDER BY c.name ASC
        ]],
        { characterId }
    ) or {}
end

local function getMessages(characterId)
    return MySQL.query.await(
        [[
            SELECT id, sender_character_id, receiver_character_id, message, created_at
            FROM whellco_messages
            WHERE sender_character_id = ? OR receiver_character_id = ?
            ORDER BY created_at DESC
            LIMIT ?
        ]],
        { characterId, characterId, Config.MaxMessages }
    ) or {}
end

local function getCalls(characterId)
    return MySQL.query.await(
        [[
            SELECT id, caller_character_id, receiver_character_id, status, started_at, ended_at
            FROM whellco_calls
            WHERE caller_character_id = ? OR receiver_character_id = ?
            ORDER BY started_at DESC
            LIMIT 25
        ]],
        { characterId, characterId }
    ) or {}
end

local function sendPhone(source, characterId)
    local phone = getOrCreatePhone(characterId)

    TriggerClientEvent('whellco_phone:openPhone', source, {
        contacts = getContacts(characterId),
        messages = getMessages(characterId),
        calls = getCalls(characterId),
        phoneNumber = phone.phone_number
    })
end

RegisterNetEvent('whellco_phone:openPhone', function()
    local source = source
    local characterId = GetPlayerIdentifierByType(source, 'license')

    if not characterId then
        return
    end

    sendPhone(source, characterId)
end)

RegisterNetEvent('whellco_phone:closePhone', function()
    local source = source

    TriggerClientEvent('whellco_phone:closePhone', source)
end)

RegisterNetEvent('whellco_phone:addContact', function(data)
    local source = source
    local characterId = GetPlayerIdentifierByType(source, 'license')

    if not characterId then
        return
    end

    local contactId = tonumber(data.contactId)
    local name = tostring(data.name or ''):gsub('^%s+', ''):gsub('%s+$', '')

    if not contactId or #name < 2 then
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_contacts
                (owner_character_id, contact_character_id, name)
            VALUES (?, ?, ?)
            ON DUPLICATE KEY UPDATE name = VALUES(name)
        ]],
        { characterId, contactId, name }
    )

    sendPhone(source, characterId)
end)

RegisterNetEvent('whellco_phone:sendMessage', function(data)
    local source = source
    local characterId = GetPlayerIdentifierByType(source, 'license')

    if not characterId then
        return
    end

    local receiverId = tonumber(data.receiverId)
    local message = tostring(data.message or ''):gsub('^%s+', ''):gsub('%s+$', '')

    if not receiverId or #message < 1 or #message > 255 then
        return
    end

    MySQL.insert.await(
        'INSERT INTO whellco_messages (sender_character_id, receiver_character_id, message) VALUES (?, ?, ?)',
        { characterId, receiverId, message }
    )

    sendPhone(source, characterId)
end)

RegisterNetEvent('whellco_phone:startCall', function(data)
    local source = source
    local characterId = GetPlayerIdentifierByType(source, 'license')

    if not characterId then
        return
    end

    local receiverId = tonumber(data.receiverId)

    if not receiverId then
        return
    end

    local callId = MySQL.insert.await(
        [[
            INSERT INTO whellco_calls
                (caller_character_id, receiver_character_id, status)
            VALUES (?, ?, 'ringing')
        ]],
        { characterId, receiverId }
    )

    activeCalls[callId] = {
        caller = characterId,
        receiver = receiverId
    }

    sendPhone(source, characterId)
end)

RegisterNetEvent('whellco_phone:endCall', function(data)
    local source = source
    local callId = tonumber(data.callId)

    if not callId then
        return
    end

    MySQL.update.await(
        [[
            UPDATE whellco_calls
            SET status = 'ended', ended_at = CURRENT_TIMESTAMP
            WHERE id = ?
        ]],
        { callId }
    )

    activeCalls[callId] = nil

    local characterId = GetPlayerIdentifierByType(source, 'license')

    if characterId then
        sendPhone(source, characterId)
    end
end)
