local QBCore = exports['qb-core']:GetCoreObject()

local lockdownCooldowns = {}
local isLockdownActive = false

local function isAuthorised(Player)
    local job = Player.PlayerData.job

    return job and (job.name == Config.ManagerJob or job.name == Config.SecurityJob)
end

RegisterNetEvent('whellco_emergency_lockdown:toggle', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isAuthorised(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not authorised to toggle lockdown.', 'error')
        return
    end

    local now = os.time()

    if now - (lockdownCooldowns[source] or 0) < Config.LockdownCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before toggling lockdown again.', 'error')
        return
    end

    lockdownCooldowns[source] = now
    isLockdownActive = not isLockdownActive

    local players = QBCore.Functions.GetQBPlayers()

    for _, target in pairs(players) do
        TriggerClientEvent('whellco_emergency_lockdown:state', target.PlayerData.source, {
            active = isLockdownActive,
            doors = Config.Doors
        })
    end

    TriggerClientEvent('QBCore:Notify', source, isLockdownActive and 'Emergency lockdown activated.' or 'Lockdown deactivated.', isLockdownActive and 'error' or 'success')
end)

RegisterCommand('lockdown', function(source)
    TriggerEvent('whellco_emergency_lockdown:toggle')
end, false)