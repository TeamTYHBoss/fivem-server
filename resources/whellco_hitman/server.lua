local QBCore = exports['qb-core']:GetCoreObject()

local activeContracts = {}
local contractCooldowns = {}

local function isAdmin(Player)
    local job = Player.PlayerData.job

    return job and Config.AdminJobs[job.name]
end

local function isHitman(Player)
    local job = Player.PlayerData.job

    return job and job.name == Config.Hitman.JobName
end

local function getContractTier(completedContracts)
    local tier = 1

    for _, contract in ipairs(Config.ContractTiers) do
        if completedContracts >= contract.tier - 1 then
            tier = contract.tier
        end
    end

    return tier
end

RegisterNetEvent('whellco_hitman:accept', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isHitman(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You must be a hitman to accept contracts.', 'error')
        return
    end

    if activeContracts[source] then
        TriggerClientEvent('QBCore:Notify', source, 'You already have an active contract.', 'error')
        return
    end

    local now = os.time()

    if now - (contractCooldowns[source] or 0) < Config.Hitman.ContractCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before accepting another contract.', 'error')
        return
    end

    local completed = Player.PlayerData.metadata['hitman_contracts'] or 0
    local tier = getContractTier(completed)
    local contract = Config.ContractTiers[tier]

    contractCooldowns[source] = now
    activeContracts[source] = {
        tier = tier,
        startedAt = os.time(),
        expiresAt = os.time() + Config.Hitman.ContractTimeSeconds
    }

    TriggerClientEvent('whellco_hitman:start', source, {
        tier = tier,
        label = contract.label,
        payout = contract.payout,
        npcCount = contract.npcCount,
        npcArmour = contract.npcArmour,
        npcWeapon = contract.npcWeapon,
        expiresAt = activeContracts[source].expiresAt
    })

    TriggerClientEvent('QBCore:Notify', source, ('Contract accepted: %s. Reward: $%d.'):format(contract.label, contract.payout), 'success')
end)

RegisterNetEvent('whellco_hitman:complete', function(success)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local contract = activeContracts[source]

    if not Player or not contract then
        return
    end

    activeContracts[source] = nil

    if not success or os.time() > contract.expiresAt then
        TriggerClientEvent('QBCore:Notify', source, 'Contract failed or expired.', 'error')
        return
    end

    local tierConfig = Config.ContractTiers[contract.tier]
    Player.Functions.AddMoney('cash', tierConfig.payout, 'hitman-contract')

    local completed = (Player.PlayerData.metadata['hitman_contracts'] or 0) + 1
    Player.Functions.SetMetaData('hitman_contracts', completed)

    MySQL.query.await(
        [[INSERT INTO whellco_hitman_contracts
            (hitman_citizenid, tier, payout, success)
          VALUES (?, ?, ?, ?)]],
        {
            Player.PlayerData.citizenid,
            contract.tier,
            tierConfig.payout,
            success and 1 or 0
        }
    )

    TriggerClientEvent('QBCore:Notify', source, ('Contract complete: $%d earned.'):format(tierConfig.payout), 'success')
end)

RegisterNetEvent('whellco_hitman:applyAppearance', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isHitman(Player) then
        return
    end

    TriggerClientEvent('whellco_hitman:applyAppearance', source, Config.Appearance)
end)

RegisterCommand('hitman', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isHitman(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not a hitman.', 'error')
        return
    end

    TriggerClientEvent('whellco_hitman:openMenu', source)
end, false)

RegisterCommand('hitmaninfo', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isAdmin(Player) then
        return
    end

    TriggerClientEvent('QBCore:Notify', source, 'Hitman contracts escalate by tier. Contract time remains constant.', 'primary')
end, false)