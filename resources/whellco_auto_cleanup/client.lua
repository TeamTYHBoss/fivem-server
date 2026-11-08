local QBCore = exports['qb-core']:GetCoreObject()

local function isExempt(entity, model)
    if Config.ExemptModels[model] then
        return true
    end

    if Config.SkipMissionEntities and IsEntityAMissionEntity(entity) then
        return true
    end

    if Config.SkipPlayerVehicles and IsEntityAPed(entity) == false and IsVehicleAPlayerVehicle(entity) then
        return true
    end

    local coords = GetEntityCoords(entity)

    for _, zone in ipairs(Config.ExemptZones) do
        if #(coords - zone.coords) <= zone.radius then
            return true
        end
    end

    return false
end

local function cleanupAbandoned()
    local now = GetGameTimer()
    local vehicleIdleMs = Config.Cleanup.VehicleIdleMinutes * 60000
    local pedIdleMs = Config.Cleanup.PedIdleMinutes * 60000
    local cleanedVehicles = 0
    local cleanedPeds = 0

    local vehicleHandle, vehicle = FindFirstVehicle()

    repeat
        if DoesEntityExist(vehicle) then
            local model = GetEntityModel(vehicle)
            local coords = GetEntityCoords(vehicle)
            local lastMoved = GetVehicleLastDrivenTime(vehicle) or 0

            if
                not isExempt(vehicle, model)
                and not isExemptZone(coords)
                and now - lastMoved > vehicleIdleMs
                and GetVehicleNumberOfPassengers(vehicle) == 0
                and cleanedVehicles < Config.Cleanup.MaxCleanupPerCycle
            then
                DeleteEntity(vehicle)
                cleanedVehicles = cleanedVehicles + 1
            end
        end

        _, vehicle = FindNextVehicle(vehicleHandle)
    until not FindNextVehicle(vehicleHandle)

    EndFindVehicle(vehicleHandle)

    local pedHandle, ped = FindFirstPed()

    repeat
        if DoesEntityExist(ped) then
            local model = GetEntityModel(ped)
            local coords = GetEntityCoords(ped)

            if
                not IsPedAPlayer(ped)
                and not isExempt(ped, model)
                and not isExemptZone(coords)
                and not IsPedInAnyVehicle(ped, false)
                and cleanedPeds < Config.Cleanup.MaxCleanupPerCycle
            then
                DeleteEntity(ped)
                cleanedPeds = cleanedPeds + 1
            end
        end

        _, ped = FindNextPed(pedHandle)
    until not FindNextPed(pedHandle)

    EndFindPed(pedHandle)

    TriggerServerEvent('whellco_auto_cleanup:report', {
        vehicles = cleanedVehicles,
        peds = cleanedPeds
    })
end

CreateThread(function()
    while true do
        Wait(Config.Cleanup.IntervalSeconds * 1000)
        cleanupAbandoned()
    end
end)

RegisterNetEvent('whellco_auto_cleanup:run', function()
    cleanupAbandoned()
end)

RegisterCommand('cleanupmanual', function()
    cleanupAbandoned()
end, false)