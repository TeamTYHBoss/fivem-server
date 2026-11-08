local QBCore = exports['qb-core']:GetCoreObject()

local function hasUniformAccess(Player, uniform)
    if not uniform.requiredJob then
        return true
    end

    local job = Player.PlayerData.job

    return job
        and job.name == uniform.requiredJob
        and (job.grade.level or 0) >= (uniform.requiredGrade or 0)
end

local function hasVehicleAccess(Player, vehicle)
    if not vehicle.requiredJob then
        return true
    end

    local job = Player.PlayerData.job

    return job
        and job.name == vehicle.requiredJob
        and (job.grade.level or 0) >= (vehicle.requiredGrade or 0)
end

RegisterNetEvent('whellco_eup_assets:requestUniform', function(name)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local uniform = Config.Uniforms[name]

    if not Player or not uniform then
        return
    end

    if not hasUniformAccess(Player, uniform) then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have access to this uniform.', 'error')
        return
    end

    TriggerClientEvent('whellco_eup_assets:applyUniform', source, name)
end)

RegisterNetEvent('whellco_eup_assets:requestOutfit', function(category, index)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local categoryConfig = Config.WardrobeCategories[category]
    local outfit = categoryConfig and categoryConfig.outfits[index]

    if not Player or not outfit then
        return
    end

    if outfit.uniform then
        local uniform = Config.Uniforms[outfit.uniform]

        if not uniform or not hasUniformAccess(Player, uniform) then
            TriggerClientEvent('QBCore:Notify', source, 'You do not have access to this uniform.', 'error')
            return
        end
    end

    TriggerClientEvent('whellco_eup_assets:applyOutfit', source, category, index)
end)

RegisterNetEvent('whellco_eup_assets:requestVehicle', function(category)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local vehicle = Config.Vehicles[category]

    if not Player or not vehicle then
        return
    end

    if not hasVehicleAccess(Player, vehicle) then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have access to this vehicle.', 'error')
        return
    end

    TriggerClientEvent('whellco_eup_assets:spawnVehicle', source, category)
end)

RegisterCommand('eupmenu', function(source)
    if source > 0 then
        local Player = QBCore.Functions.GetPlayer(source)

        if not Player then
            return
        end

        TriggerClientEvent('QBCore:Notify', source, 'EUP wardrobe and emergency vehicle menu opened.', 'primary')
    end
end, false)