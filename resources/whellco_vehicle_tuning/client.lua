local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_vehicle_tuning:applyMod', function(data)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle == 0 then
        return
    end

    if data.modType == 'engine' then
        SetVehicleModKit(vehicle, 0)
        ToggleVehicleMod(vehicle, 11, true)
        SetVehicleEnginePowerMultiplier(vehicle, 1.0 + (data.level * 0.05))
    elseif data.modType == 'brakes' then
        SetVehicleModKit(vehicle, 0)
        ToggleVehicleMod(vehicle, 12, true)
    elseif data.modType == 'transmission' then
        SetVehicleModKit(vehicle, 0)
        ToggleVehicleMod(vehicle, 13, true)
    elseif data.modType == 'turbo' then
        SetVehicleModKit(vehicle, 0)
        ToggleVehicleMod(vehicle, 18, true)
    elseif data.modType == 'suspension' then
        SetVehicleModKit(vehicle, 0)
        SetVehicleMod(vehicle, 15, data.level, false)
    elseif data.modType == 'armor' then
        SetVehicleModKit(vehicle, 0)
        SetVehicleMod(vehicle, 16, data.level, false)
    end
end)

RegisterNetEvent('whellco_vehicle_tuning:applyColor', function(data)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle == 0 then
        return
    end

    if data.colorType == 'primary' then
        SetVehicleCustomPrimaryColour(vehicle, data.r, data.g, data.b)
    elseif data.colorType == 'secondary' then
        SetVehicleCustomSecondaryColour(vehicle, data.r, data.g, data.b)
    end
end)

RegisterCommand('tuninginfo', function()
    local shops = {}

    for id, shop in pairs(Config.TuningShops) do
        shops[#shops + 1] = ('%s - %s'):format(id, shop.label)
    end

    QBCore.Functions.Notify(table.concat(shops, ', '), 'primary')
end, false)