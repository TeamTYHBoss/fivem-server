local QBCore = exports['qb-core']:GetCoreObject()

local registeredTargets = {}
local activeHighlights = {}

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

local function drawIcon(coords, icon, color)
    if not Config.VisualFeedback.enabled then
        return
    end

    local text = ('%s\n%s'):format(icon or '✦', 'Interact')

    QBCore.Functions.DrawText3D(coords.x, coords.y, coords.z, text)
end

local function highlightTarget(id, coords, color)
    if not Config.VisualFeedback.enabled then
        return
    end

    if activeHighlights[id] then
        return
    end

    local rgb = color or Config.VisualFeedback.highlightColor
    local alpha = Config.VisualFeedback.highlightAlpha or 120

    activeHighlights[id] = true

    CreateThread(function()
        local endTime = GetGameTimer() + 1500

        while GetGameTimer() < endTime do
            DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.35, 0.35, 0.35, rgb[1], rgb[2], rgb[3], alpha, false, false, 2, false, nil, nil, false)
            Wait(0)
        end

        activeHighlights[id] = nil
    end)
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
            onSelect = function(data)
                local coords = data.coords or options.coords or GetEntityCoords(PlayerPedId())

                highlightTarget(id, coords, options.feedback and options.feedback.color and {
                    tonumber(options.feedback.color:sub(2, 3), 16),
                    tonumber(options.feedback.color:sub(4, 5), 16),
                    tonumber(options.feedback.color:sub(6, 7), 16)
                } or Config.VisualFeedback.highlightColor)

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

RegisterNetEvent('whellco_ox_target:feedback', function(targetId, success, message)
    local options = Config.Targets[targetId]

    if not options then
        return
    end

    local feedback = options.feedback or {}
    local soundName = success and (feedback.sound or Config.VisualFeedback.successSound) or Config.VisualFeedback.errorSound
    local soundSet = success and (feedback.soundSet or Config.VisualFeedback.successSoundSet) or Config.VisualFeedback.errorSoundSet

    PlaySoundFrontend(-1, soundName, soundSet, true)
    QBCore.Functions.Notify(message or (success and 'Interaction complete.' or 'Interaction failed.'), success and 'success' or 'error')
end)

RegisterNetEvent('whellco_ox_target:notify', function(message, type)
    QBCore.Functions.Notify(message, type or 'primary')
end)

CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

        for id, options in pairs(Config.Targets) do
            registerTarget(id, options)

            if options.type == 'zone' then
                local distance = #(coords - options.coords)

                if distance < (options.distance or 2.5) and hasAccess(options) then
                    sleep = 0
                    drawIcon(options.coords, options.feedback and options.feedback.icon or options.icon, options.feedback and options.feedback.color)
                end
            end
        end

        Wait(sleep)
    end
end)