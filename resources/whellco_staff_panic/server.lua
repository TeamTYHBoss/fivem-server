local QBCore = exports['qb-core']:GetCoreObject()

local panicCooldowns = {}

local function isStaff(Player)
    local job = Player.PlayerData.job

    return job and Config.StaffJobs[job.name]
end

local function isNear(coords, club)
    return #(coords - club.location) <= club.radius
end

RegisterNetEvent('whellco_staff_panic:activate', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isStaff(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not authorised to use the panic button.', 'error')
        return
    end

    local now = os.time()

    if now - (panicCooldowns[source] or 0) < Config.PanicCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before activating the panic button again.', 'error')
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if not isNear(coords, Config.StripClub) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not near the club.', 'error')
        return
    end

    panicCooldowns[source] = now

    local alert = {
        source = source,
        name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        coords = coords,
        message = Config.PanicMessage,
        timestamp = os.time()
    }

    local players = QBCore.Functions.GetQBPlayers()

    for _, target in pairs(players) do
        if target.PlayerData.job.name == Config.SecurityJob then
            TriggerClientEvent('whellco_staff_panic:alert', target.PlayerData.source, alert)
        end
    end

    TriggerClientEvent('QBCore:Notify', source, 'Security has been alerted.', 'success')
end)

RegisterCommand('staffpanic', function(source)
    TriggerEvent('whellco_staff_panic:activate')
end, false)