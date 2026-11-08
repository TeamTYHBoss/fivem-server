local QBCore = exports['qb-core']:GetCoreObject()

local function applyOutfit(outfit)
    local playerPed = PlayerPedId()

    SetPedComponentVariation(playerPed, 8, outfit.tshirt or 0, 0, 2)
    SetPedComponentVariation(playerPed, 11, outfit.torso or 0, outfit.decals or 0, 2)
    SetPedComponentVariation(playerPed, 3, outfit.arms or 0, 0, 2)
    SetPedComponentVariation(playerPed, 4, outfit.pants or 0, 0, 2)
    SetPedComponentVariation(playerPed, 6, outfit.shoes or 0, 0, 2)

    if outfit.hat then
        SetPedPropIndex(playerPed, 0, outfit.hat, 0, true)
    end

    if outfit.glasses then
        SetPedPropIndex(playerPed, 1, outfit.glasses, 0, true)
    end
end

local function getUniform(name)
    local uniform = Config.Uniforms[name]

    if not uniform then
        return nil
    end

    local playerData = QBCore.Functions.GetPlayerData()
    local sex = playerData.charinfo and playerData.charinfo.gender or 0

    return sex == 1 and uniform.female or uniform.male
end

RegisterNetEvent('whellco_eup_assets:applyUniform', function(name)
    local uniform = getUniform(name)

    if not uniform then
        QBCore.Functions.Notify('Uniform not found.', 'error')
        return
    end

    applyOutfit(uniform)
    QBCore.Functions.Notify(('Applied %s.'):format(Config.Uniforms[name].label), 'success')
end)

RegisterNetEvent('whellco_eup_assets:applyOutfit', function(category, index)
    local categoryConfig = Config.WardrobeCategories[category]
    local outfit = categoryConfig and categoryConfig.outfits[index]

    if not outfit then
        QBCore.Functions.Notify('Outfit not found.', 'error')
        return
    end

    if outfit.uniform then
        local uniform = getUniform(outfit.uniform)

        if not uniform then
            QBCore.Functions.Notify('You do not have access to this uniform.', 'error')
            return
        end

        applyOutfit(uniform)
    else
        applyOutfit(outfit)
    end

    QBCore.Functions.Notify(('Applied %s.'):format(outfit.label), 'success')
end)

RegisterNetEvent('whellco_eup_assets:spawnVehicle', function(category)
    local vehicle = Config.Vehicles[category]

    if not vehicle then
        QBCore.Functions.Notify('Vehicle not available.', 'error')
        return
    end

    local model = vehicle.model

    RequestModel(model)

    local timeout = GetGameTimer() + 10000

    while not HasModelLoaded(model) and GetGameTimer() < timeout do
        Wait(25)
    end

    if not HasModelLoaded(model) then
        QBCore.Functions.Notify('Vehicle model failed to load.', 'error')
        return
    end

    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    local spawnCoords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)
    local vehicle = CreateVehicle(model, spawnCoords.x, spawnCoords.y, spawnCoords.z, heading, true, false)

    SetVehicleNumberPlateText(vehicle, 'WHELLCO')
    SetVehicleLivery(vehicle, vehicle.livery or 0)
    SetModelAsNoLongerNeeded(model)

    QBCore.Functions.Notify(('Spawned %s.'):format(vehicle.label), 'success')
end)