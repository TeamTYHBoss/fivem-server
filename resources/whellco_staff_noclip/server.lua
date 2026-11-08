local QBCore = exports['qb-core']:GetCoreObject()

local noclipCooldowns = {}

local function isStaff(Player)
    local job = Player.PlayerData.job

    return job and Config.StaffJobs[job.name]
end

RegisterNetEvent('whellco_staff_noclip:toggle', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isStaff(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not authorised to use noclip.', 'error')
        return
    end

    local now = os.time()

    if now - (noclipCooldowns[source] or 0) < Config.Noclip.cooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before toggling noclip again.', 'error')
        return
    end

    noclipCooldowns[source] = now

    TriggerClientEvent('whellco_staff_noclip:toggle', source)

    MySQL.query.await(
        [[INSERT INTO whellco_staff_noclip_logs
            (staff_citizenid, action)
          VALUES (?, 'toggle')]],
        {
            Player.PlayerData.citizenid
        }
    )
end)

RegisterCommand(Config.Noclip.command, function(source)
    TriggerEvent('whellco_staff_noclip:toggle')
end, false)