local jobCenterOpen = false

local function openJobCenter(data)
    if jobCenterOpen then
        return
    end

    jobCenterOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        jobs = data.jobs,
        applications = data.applications,
        history = data.history
    })
end

local function closeJobCenter()
    if not jobCenterOpen then
        return
    end

    jobCenterOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_jobcenter:openMenu', openJobCenter)

RegisterNetEvent('whellco_jobcenter:closeMenu', closeJobCenter)

RegisterNetEvent('whellco_jobcenter:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('jobcenter', function()
    TriggerServerEvent('whellco_jobcenter:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_jobcenter:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('applyForJob', function(data, cb)
    TriggerServerEvent('whellco_jobcenter:applyForJob', data.jobId)
    cb({ ok = true })
end)

RegisterNuiCallback('startJob', function(data, cb)
    TriggerServerEvent('whellco_jobcenter:startJob', data.jobId)
    cb({ ok = true })
end)

RegisterNuiCallback('completeJob', function(data, cb)
    TriggerServerEvent('whellco_jobcenter:completeJob', data.jobId)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
