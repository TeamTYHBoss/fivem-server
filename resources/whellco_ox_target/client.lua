local QBCore = exports['qb-core']:GetCoreObject()

local registeredTargets = {}

local function hasAccess(options)
    if not options.requiredJob then
        return true
    end

    local playerData = QBCore.Functions.GetPlayerData()
    local job = playerData.job

    return job
        and job.name == options.requiredJob
        and (job.grade.level or 0) >= (options.jobGrade or 0)
end

local function buildOptions(id, options)
    return {
        {
            name = id,
            icon = options.icon,
            label = options.label,
            distance = options.distance or 2.5,
            canInteract = function()
                return hasAccess(options)
            end,
            onSelect = function()
                TriggerServerEvent('whellco_ox_target:interact', id)
            end
        }
    }
end

local function registerTarget(id, options)
    if registeredTargets[id] then
        return
    end

    if options.type == 'model' then
        exports.ox_target:addModel(options.model, buildOptions(id, options))
    elseif options.type == 'vehicle' then
        exports.ox_target:addGlobalVehicle(buildOptions(id, options))
    elseif options.type == 'ped' then
        exports.ox_target:addGlobalPed(buildOptions(id, options))
    elseif options.type == 'zone' then
        exports.ox_target:addBoxZone({
            coords = options.coords,
            size = options.size,
            rotation = options.rotation or 0.0,
            options = buildOptions(id, options)
        })
    end

    registeredTargets[id] = true

    if Config.Debug then
        print(('[whellco_ox_target] Registered target: %s'):format(id))
    end
end

CreateThread(function()
    while true do
        for id, options in pairs(Config.Targets) do
            registerTarget(id, options)
        end

        Wait(30000)
    end
end)

RegisterNetEvent('whellco_ox_target:notify', function(message, type)
    QBCore.Functions.Notify(message, type or 'primary')
end)