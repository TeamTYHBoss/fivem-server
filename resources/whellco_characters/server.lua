local QBCore = exports['qb-core']:GetCoreObject()

local activeCharacters = {}

local function getQbPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

local function getCharacters(citizenId)
    return MySQL.query.await(
        'SELECT id, first_name, last_name, date_of_birth, gender, spawn_point FROM whellco_characters WHERE identifier = ? ORDER BY created_at ASC',
        { citizenId }
    ) or {}
end

local function sendCharacterMenu(source)
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    local characters = getCharacters(Player.PlayerData.citizenid)
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

    deferrals.defer()
    Wait(0)
    deferrals.update('Loading your characters…')

    if not getQbPlayer(source) then
        deferrals.done('Unable to identify your QBCore character.')
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
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    local citizenId = Player.PlayerData.citizenid
    local firstName = tostring(data.firstName or ''):gsub('^%s+', ''):gsub('%s+$', '')
    local lastName = tostring(data.lastName or ''):gsub('^%s+', ''):gsub('%s+$', '')
    local dateOfBirth = tostring(data.dateOfBirth or '')
    local gender = tostring(data.gender or 'other')
    local spawnPoint = tostring(data.spawnPoint or 'legion_square')

    if #firstName < 2 or #firstName > 32 or #lastName < 2 or #lastName > 32 then
        TriggerClientEvent('QBCore:Notify', source, 'Enter a valid first and last name.', 'error')
        return
    end

    if not dateOfBirth:match('^%d%d%d%d%-%d%d%-%d%d$') then
        TriggerClientEvent('QBCore:Notify', source, 'Enter a valid date of birth.', 'error')
        return
    end

    if not Config.SpawnPoints[spawnPoint] then
        spawnPoint = 'legion_square'
    end

    local count = MySQL.scalar.await(
        'SELECT COUNT(*) FROM whellco_characters WHERE identifier = ?',
        { citizenId }
    ) or 0

    if count >= Config.MaxCharacters then
        TriggerClientEvent('QBCore:Notify', source, 'You have reached the character limit.', 'error')
        return
    end

    MySQL.insert.await(
        [[
            INSERT INTO whellco_characters
                (identifier, first_name, last_name, date_of_birth, gender, spawn_point)
            VALUES (?, ?, ?, ?, ?, ?)
        ]],
        { citizenId, firstName, lastName, dateOfBirth, gender, spawnPoint }
    )

    sendCharacterMenu(source)
end)

RegisterNetEvent('whellco_characters:selectCharacter', function(characterId)
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    local character = MySQL.single.await(
        'SELECT id, first_name, last_name, spawn_point FROM whellco_characters WHERE id = ? AND identifier = ? LIMIT 1',
        { characterId, Player.PlayerData.citizenid }
    )

    if not character then
        return
    end

    local spawn = Config.SpawnPoints[character.spawn_point] or Config.SpawnPoints.legion_square

    activeCharacters[Player.PlayerData.citizenid] = character.id

    TriggerEvent('whellco_economy:characterSelected', character.id, source)

    TriggerClientEvent('whellco_characters:spawnCharacter', source, {
        character = character,
        spawn = spawn.coords
    })
end)

RegisterNetEvent('whellco_characters:deleteCharacter', function(characterId)
    local source = source
    local Player = getQbPlayer(source)

    if not Player then
        return
    end

    MySQL.update.await(
        'DELETE FROM whellco_characters WHERE id = ? AND identifier = ?',
        { characterId, Player.PlayerData.citizenid }
    )

    sendCharacterMenu(source)
end)

AddEventHandler('playerDropped', function()
    local Player = getQbPlayer(source)

    if Player then
        activeCharacters[Player.PlayerData.citizenid] = nil
    end
end)