local QBCore = exports['qb-core']:GetCoreObject()

local currentVehicle = nil

local function applyHandling(handling)
    local vehicle = currentVehicle

    if not vehicle or not handling then
        return
    end

    if handling.fInitialDriveForce then
        SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fInitialDriveForce', handling.fInitialDriveForce)
    end

    if handling.fInitialDragCoeff then
        SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fInitialDragCoeff', handling.fInitialDragCoeff)
    end

    if handling.fBrakeForce then
        SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fBrakeForce', handling.fBrakeForce)
    end

    if handling.fBrakeBiasFront then
        SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fBrakeBiasFront', handling.fBrakeBiasFront)
    end

    if handling.fTractionCurveMax then
        SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMax', handling.fTractionCurveMax)
    end

    if handling.fTractionCurveMin then
        SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMin', handling.fTractionCurveMin)
    end

    if handling.fTractionCurveLateral then
        SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveLateral', handling.fTractionCurveLateral)
    end

    if handling.fSuspensionForce then
        SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fSuspensionForce', handling.fSuspensionForce)
    end

    if handling.fSuspensionCompDamp then
        SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fSuspensionCompDamp', handling.fSuspensionCompDamp)
    end

    if handling.fSuspensionReboundDamp then
        SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fSuspensionReboundDamp', handling.fSuspensionReboundDamp)
    end
end

RegisterNetEvent('whellco_vehicle_handling:applyTuning', function(data)
    local vehicle = currentVehicle

    if not vehicle then
        return
    end

    local level = data.level or 0

    if data.category == 'engine' then
        SetVehicleModKit(vehicle, 0)
        SetVehicleMod(vehicle, 11, level, false)
    elseif data.category == 'brakes' then
        SetVehicleModKit(vehicle, 0)
        SetVehicleMod(vehicle, 12, level, false)
    elseif data.category == 'transmission' then
        SetVehicleModKit(vehicle, 0)
        SetVehicleMod(vehicle, 13, level, false)
    elseif data.category == 'suspension' then
        SetVehicleModKit(vehicle, 0)
        SetVehicleMod(vehicle, 15, level, false)
    elseif data.category == 'turbo' then
        ToggleVehicleMod(vehicle, 18, level > 0)
    elseif data.category == 'tires' then
        SetVehicleModKit(vehicle, 0)
        SetVehicleMod(vehicle, 23, level, false)
    elseif data.category == 'armor' then
        SetVehicleModKit(vehicle, 0)
        SetVehicleMod(vehicle, 16, level, false)
    end
end)

RegisterNetEvent('whellco_vehicle_handling:applyHandling', function(data)
    applyHandling(data.handling)
end)

CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()

        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)

            if vehicle ~= currentVehicle then
                currentVehicle = vehicle
            end

            sleep = 1000
        else
            currentVehicle = nil
        end

        Wait(sleep)
    end
end)