local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
    while true do
        Wait(Config.Performance.SampleIntervalSeconds * 1000)

        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local peds = 0
        local vehicles = 0
        local objects = 0

        local handle, ped = FindFirstPed()

        repeat
            if DoesEntityExist(ped) then
                peds = peds + 1
            end

            _, ped = FindNextPed(handle)
        until not FindNextPed(handle)

        EndFindPed(handle)

        local vehicleHandle, vehicle = FindFirstVehicle()

        repeat
            if DoesEntityExist(vehicle) then
                vehicles = vehicles + 1
            end

            _, vehicle = FindNextVehicle(vehicleHandle)
        until not FindNextVehicle(vehicleHandle)

        EndFindVehicle(vehicleHandle)

        local objectHandle, object = FindFirstObject()

        repeat
            if DoesEntityExist(object) then
                objects = objects + 1
            end

            _, object = FindNextObject(objectHandle)
        until not FindNextObject(objectHandle)

        EndFindObject(objectHandle)

        TriggerServerEvent('whellco_anti_lag:entityReport', {
            peds = peds,
            vehicles = vehicles,
            objects = objects,
            coords = coords
        })

        TriggerServerEvent('whellco_anti_lag:performance', {
            tickRate = GetFrameTime() * 1000
        })
    end
end)

RegisterCommand('antilaginfo', function()
    QBCore.Functions.Notify('Anti-lag monitoring is active.', 'primary')
end, false)