local interactions = {}
local activeJob = nil
local jobVehicle = nil
local currentStop = nil

local function addInteraction(id, data)
    interactions[id] = data
end

local function drawInteraction(data)
    local coords = data.coords

    DrawMarker(
        1,
        coords.x, coords.y, coords.z - 0.95,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        1.4, 1.4, 0.7,
        0, 190, 255, 110,
        false, true, 2, false, nil, nil, false
    )

    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(('Press ~INPUT_CONTEXT~ for %s'):format(data.label))
    EndTextCommandDisplayHelp(0, false, true, -1)
end

CreateThread(function()
    for shopId, shop in pairs(Config.Shops) do
        addInteraction('shop_' .. shopId, {
            type = 'shop',
            label = shop.label,
            coords = shop.coords,
            shopId = shopId
        })
    end

    for stopId, stop in pairs(Config.Transport) do
        addInteraction('transport_' .. stopId, {
            type = 'transport',
            label = stop.label,
            coords = stop.coords,
            stopId = stopId
        })
    end

    for serviceId, service in pairs(Config.Services) do
        addInteraction('service_' .. serviceId, {
            type = 'service',
            label = service.label,
            coords = service.coords,
            serviceId = serviceId
        })
    end

    for jobId, job in pairs(Config.Jobs) do
        addInteraction('job_' .. jobId, {
            type = 'job',
            label = job.label,
            coords = job.start,
            jobId = jobId
        })
    end

    for stationIndex, station in ipairs(Config.FuelStations) do
        addInteraction('fuel_' .. stationIndex, {
            type = 'fuel',
            label = station.label,
            coords = station.coords,
            stationIndex = stationIndex
        })
    end

    while true do
        local sleep = 1000
        local playerCoords = GetEntityCoords(PlayerPedId())

        for _, interaction in pairs(interactions) do
            local distance = #(playerCoords - interaction.coords)

            if distance < 20.0 then
                sleep = 0
                drawInteraction(interaction)

                if distance <= 2.5 and IsControlJustReleased(0, 38) then
                    TriggerServerEvent('whellco_immersion:interact', interaction.type, interaction)
                end
            end
        end

        if currentStop then
            sleep = 0

            local distance = #(playerCoords - currentStop.coords)

            DrawMarker(
                1,
                currentStop.coords.x, currentStop.coords.y, currentStop.coords.z - 0.95,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                3.0, 3.0, 1.0,
                0, 255, 120, 150,
                false, true, 2, false, nil, nil, false
            )

            if distance <= 4.0 and IsControlJustReleased(0, 38) then
                TriggerServerEvent('whellco_immersion:completeStop')
            end
        end

        Wait(sleep)
    end
end)

RegisterNetEvent('whellco_immersion:startJob', function(jobId, vehicleModel, mission)
    activeJob = jobId
    currentStop = mission.stops[1]

    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(('Job started: %s. Complete %d stop(s).'):format(jobId, #mission.stops))
    EndTextCommandThefeedPostTicker(false, true)

    if vehicleModel then
        RequestModel(joaat(vehicleModel))

        while not HasModelLoaded(joaat(vehicleModel)) do
            Wait(10)
        end

        local playerCoords = GetEntityCoords(PlayerPedId())
        jobVehicle = CreateVehicle(joaat(vehicleModel), playerCoords.x + 3.0, playerCoords.y, playerCoords.z, 0.0, true, false)

        SetModelAsNoLongerNeeded(joaat(vehicleModel))
        SetVehicleNumberPlateText(jobVehicle, 'WHELLCO')
        SetVehicleFuelLevel(jobVehicle, 100.0)

        TaskWarpPedIntoVehicle(PlayerPedId(), jobVehicle, -1)
    end
end)

RegisterNetEvent('whellco_immersion:nextStop', function(stop)
    currentStop = stop

    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName('Stop completed. Travel to the next destination.')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterNetEvent('whellco_immersion:completeJob', function(message)
    activeJob = nil
    currentStop = nil

    if jobVehicle then
        DeleteVehicle(jobVehicle)
        jobVehicle = nil
    end

    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or 'Job completed.')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterNetEvent('whellco_immersion:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterNetEvent('whellco_immersion:teleport', function(coords)
    local ped = PlayerPedId()

    DoScreenFadeOut(400)
    Wait(400)

    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)

    Wait(400)
    DoScreenFadeIn(400)
end)
