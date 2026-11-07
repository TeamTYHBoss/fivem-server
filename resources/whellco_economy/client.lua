local shopOpen = false
local jobBoardOpen = false
local activeJob = nil
local activeRouteIndex = nil
local jobVehicle = nil

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

local function openJobBoard(data)
    if jobBoardOpen then
        return
    end

    jobBoardOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openJobBoard',
        jobs = data.jobs
    })
end

local function closeJobBoard()
    if not jobBoardOpen then
        return
    end

    jobBoardOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'closeJobBoard'
    })
end

local function deleteJobVehicle()
    if jobVehicle and DoesEntityExist(jobVehicle) then
        DeleteVehicle(jobVehicle)
    end

    jobVehicle = nil
end

local function spawnJobVehicle(jobId)
    local job = Config.Jobs[jobId]

    if not job then
        return
    end

    deleteJobVehicle()

    local model = GetHashKey(job.vehicle)

    RequestModel(model)

    local timeout = GetGameTimer() + 5000

    while not HasModelLoaded(model) and GetGameTimer() < timeout do
        Wait(0)
    end

    if not HasModelLoaded(model) then
        return
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    jobVehicle = CreateVehicle(model, coords.x + 3.0, coords.y + 3.0, coords.z, 0.0, true, false)

    if jobVehicle and DoesEntityExist(jobVehicle) then
        TaskWarpPedIntoVehicle(ped, jobVehicle, -1)
    end

    SetModelAsNoLongerNeeded(model)
end

RegisterNetEvent('whellco_economy:openShop', openShop)

RegisterNetEvent('whellco_economy:openJobBoard', openJobBoard)

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
    activeRouteIndex = data.routeIndex or 1

    spawnJobVehicle(data.id)

    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(('Started %s job.'):format(data.label or 'job'))
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterNetEvent('whellco_economy:routeAdvanced', function(data)
    activeRouteIndex = data.routeIndex

    if data.completed then
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName('Route complete. Return to the depot to finish.')
        EndTextCommandThefeedPostTicker(false, true)
    end
end)

RegisterNetEvent('whellco_economy:jobCompleted', function()
    activeJob = nil
    activeRouteIndex = nil
    deleteJobVehicle()
end)

RegisterCommand('shop', function()
    TriggerServerEvent('whellco_economy:openShop', 'legion_247')
end, false)

RegisterCommand('jobs', function()
    TriggerServerEvent('whellco_economy:openJobBoard')
end, false)

RegisterNuiCallback('closeJobBoard', function(_, cb)
    closeJobBoard()
    cb({ ok = true })
end)

RegisterNuiCallback('startJob', function(data, cb)
    TriggerServerEvent('whellco_economy:startJob', data.jobId)
    cb({ ok = true })
end)

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

            if job then
                local waypoint = job.route[activeRouteIndex]

                if waypoint then
                    if #(coords - waypoint) < 30.0 then
                        sleep = 0

                        DrawMarker(2, waypoint.x, waypoint.y, waypoint.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 150, 255, 150, true, false, 2, false, nil, nil, false)
                    end

                    if #(coords - waypoint) < 5.0 then
                        TriggerServerEvent('whellco_economy:advanceRoute')
                    end
                elseif #(coords - job.complete) < 30.0 then
                    sleep = 0

                    DrawMarker(2, job.complete.x, job.complete.y, job.complete.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 150, 255, 150, true, false, 2, false, nil, nil, false)
                end
            end
        end

        Wait(sleep)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
        deleteJobVehicle()
    end
end)
