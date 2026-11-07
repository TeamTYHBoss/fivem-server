local shopOpen = false
local activeJob = nil

local function openShop(data)
    if shopOpen then
        return
    end

    shopOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        shop = data
    })
end

RegisterNetEvent('whellco_economy:openShop', openShop)

RegisterNetEvent('whellco_economy:updateAccount', function(account)
    SendNUIMessage({
        action = 'updateAccount',
        account = account
    })
end)

RegisterNetEvent('whellco_economy:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterNetEvent('whellco_economy:levelUp', function(level)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(('Level up! You are now level %d.'):format(level))
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterNetEvent('whellco_economy:jobStarted', function(data)
    activeJob = data.id

    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(('Started %s job.'):format(data.label or 'job'))
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterNetEvent('whellco_economy:jobCompleted', function()
    activeJob = nil
end)

RegisterCommand('shop', function()
    TriggerServerEvent('whellco_economy:openShop', 'legion_247')
end, false)

RegisterCommand('jobs', function()
    local lines = {}

    for id, job in pairs(Config.Jobs) do
        lines[#lines + 1] = ('%s - %s'):format(id, job.label)
    end

    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(table.concat(lines, ' | '))
    EndTextCommandThefeedPostTicker(false, true)
end, false)

RegisterCommand('startjob', function(_, args)
    local jobId = args[1]

    if not jobId then
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName('Usage: /startjob taxi')
        EndTextCommandThefeedPostTicker(false, true)
        return
    end

    TriggerServerEvent('whellco_economy:startJob', jobId)
end, false)

RegisterCommand('finishjob', function()
    TriggerServerEvent('whellco_economy:completeJob')
end, false)

CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        if not activeJob then
            for _, job in pairs(Config.Jobs) do
                if #(coords - job.start) < 30.0 then
                    sleep = 0

                    DrawMarker(2, job.start.x, job.start.y, job.start.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 255, 150, 150, true, false, 2, false, nil, nil, false)
                end
            end
        else
            local job = Config.Jobs[activeJob]

            if job and #(coords - job.complete) < 30.0 then
                sleep = 0

                DrawMarker(2, job.complete.x, job.complete.y, job.complete.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 150, 255, 150, true, false, 2, false, nil, nil, false)
            end
        end

        Wait(sleep)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
