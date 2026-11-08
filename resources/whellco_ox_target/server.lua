local QBCore = exports['qb-core']:GetCoreObject()

local function hasAccess(Player, options)
    if not options.requiredJob then
        return true
    end

    local job = Player.PlayerData.job

    return job
        and job.name == options.requiredJob
        and (job.grade.level or 0) >= (options.jobGrade or 0)
end

RegisterNetEvent('whellco_ox_target:interact', function(targetId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local options = Config.Targets[targetId]

    if not options then
        TriggerClientEvent('whellco_ox_target:feedback', source, targetId, false, 'Invalid interaction.')
        return
    end

    if not hasAccess(Player, options) then
        TriggerClientEvent('whellco_ox_target:feedback', source, targetId, false, 'You do not have access to this interaction.')
        return
    end

    local success = true
    local message = 'Interaction completed.'

    if options.event == 'whellco_ox_target:openArmory' then
        message = 'Armory opened.'
    elseif options.event == 'whellco_ox_target:repairVehicle' then
        message = 'Vehicle repair started.'
    elseif options.event == 'whellco_ox_target:talkToMechanic' then
        message = 'The mechanic is ready to help.'
    elseif options.event == 'whellco_ox_target:openStash' then
        message = 'Stash opened.'
    end

    TriggerClientEvent('whellco_ox_target:feedback', source, targetId, success, message)
end)