local activeCharacters = {}

local function getIdentifier(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')

    if not identifier then
        identifier = GetPlayerIdentifierByType(source, 'steam')
    end

    return identifier
end

local function getCharacters(identifier)
    return MySQL.query.await(
        'SELECT id, first_name, last_name, date_of_birth, gender, spawn_point FROM whellco_characters WHERE identifier = ? ORDER BY created_at ASC',
        { identifier }
    ) or {}
end

local function sendCharacterMenu(source)
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local characters = getCharacters(identifier)
    local spawnPoints = {}

    for id, spawn in pairs(Config.SpawnPoints) do
        spawnPoints[#spawnPoints + 1] = {
            id = id,
            label = spawn.label
        }
    end

    TriggerClientEvent('whellco_characters:openMenu', source, {
        characters = characters,
        spawnPoints = spawnPoints,
        maxCharacters = Config.MaxCharacters
    })
end

AddEventHandler('playerConnecting', function(_, _, deferrals)
    local source = source
    local identifier = getIdentifier(source)

    deferrals.defer()
    Wait(0)
    deferrals.update('Loading your characters…')

    if not identifier then
        deferrals.done('Unable to identify your account.')
        return
    end

    deferrals.done()
end)

AddEventHandler('playerSpawned', function()
    local source = source

    Wait(1000)
    sendCharacterMenu(source)
end)

RegisterNetEvent('whellco_characters:closeMenu', function()
    local source = source

    TriggerClientEvent('whellco_characters:closeMenu', source)
end)

RegisterNetEvent('whellco_characters:createCharacter', function(data)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local firstName = tostring(data.firstName or ''):gsub('^%s+', ''):gsub('%s+$', '')
    local lastName = tostring(data.lastName or ''):gsub('^%s+', ''):gsub('%s+$', '')
    local dateOfBirth = tostring(data.dateOfBirth or '')
    local gender = tostring(data.gender or 'other')
    local spawnPoint = tostring(data.spawnPoint or 'legion_square')

    if #firstName < 2 or #firstName > 32 or #lastName < 2 or #lastName > 32 then
        TriggerClientEvent('whellco_characters:notify', source, 'Enter a valid first and last name.')
        return
    end

    if not dateOfBirth:match('^%d%d%d%d%-%d%d%-%d%d$') then
        TriggerClientEvent('whellco_characters:notify', source, 'Enter a valid date of birth.')
        return
    end

    if not Config.SpawnPoints[spawnPoint] then
        spawnPoint = 'legion_square'
    end

    local count = MySQL.scalar.await(
        'SELECT COUNT(*) FROM whellco_characters WHERE identifier = ?',
        { identifier }
    ) or 0

    if count >= Config.MaxCharacters then
        TriggerClientEvent('whellco_characters:notify', source, 'You have reached the character limit.')
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_characters
                (identifier, first_name, last_name, date_of_birth, gender, spawn_point)
            VALUES (?, ?, ?, ?, ?, ?)
        ]],
        { identifier, firstName, lastName, dateOfBirth, gender, spawnPoint }
    )

    sendCharacterMenu(source)
end)

RegisterNetEvent('whellco_characters:selectCharacter', function(characterId)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    local character = MySQL.single.await(
        'SELECT id, first_name, last_name, spawn_point FROM whellco_characters WHERE id = ? AND identifier = ? LIMIT 1',
        { characterId, identifier }
    )

    if not character then
        return
    end

    local spawn = Config.SpawnPoints[character.spawn_point] or Config.SpawnPoints.legion_square

    activeCharacters[identifier] = character.id

    TriggerEvent('whellco_economy:characterSelected', character.id, source)

    TriggerClientEvent('whellco_characters:spawnCharacter', source, {
        character = character,
        spawn = spawn.coords
    })
end)

RegisterNetEvent('whellco_characters:deleteCharacter', function(characterId)
    local source = source
    local identifier = getIdentifier(source)

    if not identifier then
        return
    end

    MySQL.update.await(
        'DELETE FROM whellco_characters WHERE id = ? AND identifier = ?',
        { characterId, identifier }
    )

    sendCharacterMenu(source)
end)

AddEventHandler('playerDropped', function()
    local identifier = getIdentifier(source)

    if identifier then
        activeCharacters[identifier] = nil
    end
end)
