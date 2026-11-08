local QBCore = exports['qb-core']:GetCoreObject()

local activeWars = {}
local territoryCooldowns = {}

local function isGangMember(Player)
    local gang = Player.PlayerData.gang

    return gang and Config.AllowedGangs[gang.name]
end

local function getTerritory(territoryId)
    return MySQL.single.await(
        [[
            SELECT id, owner_gang, captured_at
            FROM whellco_gang_territories
            WHERE territory_id = ?
        ]],
        { territoryId }
    )
end

local function createTerritory(territoryId)
    MySQL.insert.await(
        [[
            INSERT INTO whellco_gang_territories
                (territory_id, owner_gang)
            VALUES (?, 'unclaimed')
        ]],
        { territoryId }
    )
end

local function countGangMembers(territoryId, gangName)
    local players = QBCore.Functions.GetQBCorePlayers()
    local count = 0
    local config = Config.Territories[territoryId]

    for _, Player in pairs(players) do
        local gang = Player.PlayerData.gang

        if gang and gang.name == gangName then
            local coords = GetEntityCoords(GetPlayerPed(Player.PlayerData.source))

            if #(coords - config.center) <= config.radius then
                count = count + 1
            end
        end
    end

    return count
end

RegisterNetEvent('whellco_gang_territory:startWar', function(territoryId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isGangMember(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not in an eligible gang.', 'error')
        return
    end

    local territory = getTerritory(territoryId)
    local config = Config.Territories[territoryId]

    if not territory or not config then
        TriggerClientEvent('QBCore:Notify', source, 'Territory not found.', 'error')
        return
    end

    if activeWars[territoryId] then
        TriggerClientEvent('QBCore:Notify', source, 'A turf war is already active here.', 'error')
        return
    end

    local now = os.time()

    if now - (territoryCooldowns[territoryId] or 0) < Config.TerritoryCooldownMinutes * 60 then
        TriggerClientEvent('QBCore:Notify', source, 'This territory is still on cooldown.', 'error')
        return
    end

    local attackerGang = Player.PlayerData.gang.name
    local defenderGang = territory.owner_gang

    if attackerGang == defenderGang then
        TriggerClientEvent('QBCore:Notify', source, 'Your gang already owns this territory.', 'error')
        return
    end

    local attackers = countGangMembers(territoryId, attackerGang)
    local defenders = countGangMembers(territoryId, defenderGang)

    if attackers < Config.MinAttackers then
        TriggerClientEvent('QBCore:Notify', source, ('Need at least %d attackers in the territory.'):format(Config.MinAttackers), 'error')
        return
    end

    if defenderGang ~= 'unclaimed' and defenders < Config.MinDefenders then
        TriggerClientEvent('QBCore:Notify', source, ('Need at least %d defenders in the territory.'):format(Config.MinDefenders), 'error')
        return
    end

    activeWars[territoryId] = {
        attackerGang = attackerGang,
        defenderGang = defenderGang,
        startedAt = now,
        endsAt = now + Config.TerritoryCaptureTime
    }

    TriggerClientEvent('whellco_gang_territory:warStarted', -1, {
        territoryId = territoryId,
        label = config.label,
        attackerGang = attackerGang,
        defenderGang = defenderGang,
        endsAt = activeWars[territoryId].endsAt
    })
end)

RegisterNetEvent('whellco_gang_territory:claimTerritory', function(territoryId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local war = activeWars[territoryId]

    if not Player or not war or not isGangMember(Player) then
        return
    end

    if Player.PlayerData.gang.name ~= war.attackerGang then
        return
    end

    local now = os.time()

    if now < war.endsAt then
        TriggerClientEvent('QBCore:Notify', source, 'The turf war is still active.', 'error')
        return
    end

    MySQL.update.await(
        [[
            UPDATE whellco_gang_territories
            SET owner_gang = ?, captured_at = CURRENT_TIMESTAMP
            WHERE territory_id = ?
        ]],
        { war.attackerGang, territoryId }
    )

    activeWars[territoryId] = nil
    territoryCooldowns[territoryId] = now

    Player.Functions.AddMoney('bank', Config.RewardMoney, 'Territory capture reward')
    Player.Functions.SetMetaData('whellco_xp', (Player.PlayerData.metadata.whellco_xp or 0) + Config.RewardXp)

    TriggerClientEvent('whellco_gang_territory:warEnded', -1, {
        territoryId = territoryId,
        winnerGang = war.attackerGang,
        reward = Config.RewardMoney
    })
end)

RegisterCommand('territories', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local names = {}

    for id, territory in pairs(Config.Territories) do
        names[#names + 1] = ('%s - %s'):format(id, territory.label)
    end

    TriggerClientEvent('QBCore:Notify', source, table.concat(names, ', '), 'primary')
end, false)

RegisterCommand('startwar', function(source, args)
    local territoryId = args[1]

    if not territoryId then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /startwar [territory_id]', 'error')
        return
    end

    TriggerEvent('whellco_gang_territory:startWar', territoryId)
end, false)

RegisterCommand('claimterritory', function(source, args)
    local territoryId = args[1]

    if not territoryId then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /claimterritory [territory_id]', 'error')
        return
    end

    TriggerEvent('whellco_gang_territory:claimTerritory', territoryId)
end, false)