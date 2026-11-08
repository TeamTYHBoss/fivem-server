local QBCore = exports['qb-core']:GetCoreObject()

local activeDisguises = {}
local disguiseCooldowns = {}
local guardChallengeCooldowns = {}

local function isAdmin(Player)
    local job = Player.PlayerData.job

    return job and Config.AdminJobs[job.name]
end

local function hasRequiredItem(Player)
    return Player.Functions.GetItemByName(Config.Disguise.RequiredItem) ~= nil
end

local function canUseDisguise(source)
    local now = os.time()

    if now - (disguiseCooldowns[source] or 0) < Config.Disguise.CooldownSeconds then
        return false
    end

    disguiseCooldowns[source] = now

    return true
end

local function canChallengeGuard(source)
    local now = os.time()

    if now - (guardChallengeCooldowns[source] or 0) < Config.Disguise.GuardChallengeCooldownSeconds then
        return false
    end

    guardChallengeCooldowns[source] = now

    return true
end

RegisterNetEvent('whellco_disguise_entry:enter', function(areaName)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    if activeDisguises[source] then
        TriggerClientEvent('QBCore:Notify', source, 'You are already disguised.', 'error')
        return
    end

    if not hasRequiredItem(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You need a disguise kit.', 'error')
        return
    end

    if not canUseDisguise(source) then
        TriggerClientEvent('QBCore:Notify', source, 'You must wait before using another disguise.', 'error')
        return
    end

    local area = nil

    for _, restrictedArea in ipairs(Config.RestrictedAreas) do
        if restrictedArea.name == areaName then
            area = restrictedArea
            break
        end
    end

    if not area then
        return
    end

    Player.Functions.RemoveItem(Config.Disguise.RequiredItem, 1)

    activeDisguises[source] = {
        area = area.name,
        disguise = area.requiredDisguise,
        expiresAt = os.time() + Config.Disguise.EntryDurationSeconds
    }

    TriggerClientEvent('whellco_disguise_entry:apply', source, {
        area = area,
        disguise = Config.DisguiseOutfits[area.requiredDisguise],
        expiresAt = activeDisguises[source].expiresAt
    })

    MySQL.query.await(
        [[INSERT INTO whellco_disguise_entries
            (player_citizenid, area_name, disguise_type, detected)
          VALUES (?, ?, ?, ?)]],
        {
            Player.PlayerData.citizenid,
            area.name,
            area.requiredDisguise,
            0
        }
    )

    TriggerClientEvent('QBCore:Notify', source, ('Disguise active: %s.'):format(area.name), 'success')
end)

RegisterNetEvent('whellco_disguise_entry:guardChallenge', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local disguise = activeDisguises[source]

    if not Player or not disguise then
        return
    end

    if not canChallengeGuard(source) then
        return
    end

    TriggerClientEvent('whellco_disguise_entry:guardPrompt', source)
end)

RegisterNetEvent('whellco_disguise_entry:guardResponse', function(response)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local disguise = activeDisguises[source]

    if not Player or not disguise then
        return
    end

    if response ~= 'convince' then
        activeDisguises[source] = nil
        TriggerClientEvent('whellco_disguise_entry:remove', source)
        TriggerClientEvent('QBCore:Notify', source, 'You failed the guard challenge.', 'error')

        MySQL.query.await(
            [[UPDATE whellco_disguise_entries
              SET detected = 1
              WHERE player_citizenid = ? AND area_name = ? AND detected = 0
              ORDER BY id DESC
              LIMIT 1]],
            {
                Player.PlayerData.citizenid,
                disguise.area
            }
        )

        return
    end

    TriggerClientEvent('QBCore:Notify', source, 'You convinced the guard.', 'success')
end)

RegisterNetEvent('whellco_disguise_entry:detect', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local disguise = activeDisguises[source]

    if not Player or not disguise then
        return
    end

    activeDisguises[source] = nil

    TriggerClientEvent('whellco_disguise_entry:remove', source)

    MySQL.query.await(
        [[UPDATE whellco_disguise_entries
          SET detected = 1
          WHERE player_citizenid = ? AND area_name = ? AND detected = 0
          ORDER BY id DESC
          LIMIT 1]],
        {
            Player.PlayerData.citizenid,
            disguise.area
        }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Your disguise was detected.', 'error')

    for job, enabled in pairs(Config.Disguise.AlertJobs) do
        if enabled then
            TriggerClientEvent('whellco_disguise_entry:alert', -1, job, GetEntityCoords(GetPlayerPed(source)))
        end
    end
end)

RegisterCommand('disguiseinfo', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isAdmin(Player) then
        return
    end

    TriggerClientEvent('QBCore:Notify', source, 'Guards can challenge disguised players with a prompt.', 'primary')
end, false)