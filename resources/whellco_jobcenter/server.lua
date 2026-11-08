local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_jobcenter:openMenu', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    TriggerClientEvent('whellco_jobcenter:openMenu', source, {
        currentJob = Player.PlayerData.job.label,
        grade = Player.PlayerData.job.grade.level
    })
end)

RegisterNetEvent('whellco_jobcenter:applyForJob', function(jobId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local job = Config.Jobs[jobId]

    if not Player or not job then
        return
    end

    Player.Functions.SetJob(jobId, 0)

    TriggerClientEvent('QBCore:Notify', source, ('You are now employed as %s.'):format(job.label), 'success')
end)