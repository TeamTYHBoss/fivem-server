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
        TriggerClientEvent('whellco_ox_target:notify', source, 'Invalid interaction.', 'error')
        return
    end

    if not hasAccess(Player, options) then
        TriggerClientEvent('whellco_ox_target:notify', source, 'You do not have access to this interaction.', 'error')
        return
    end

    if options.event == 'whellco_ox_target:openArmory' then
        TriggerClientEvent('whellco_ox_target:notify', source, 'Armory opened.', 'success')
    elseif options.event == 'whellco_ox_target:repairVehicle' then
        TriggerClientEvent('whellco_ox_target:notify', source, 'Vehicle repair started.', 'success')
    elseif options.event == 'whellco_ox_target:talkToMechanic' then
        TriggerClientEvent('whellco_ox_target:notify', source, 'The mechanic is ready to help.', 'success')
    elseif options.event == 'whellco_ox_target:openStash' then
        TriggerClientEvent('whellco_ox_target:notify', source, 'Stash opened.', 'success')
    else
        TriggerClientEvent('whellco_ox_target:notify', source, 'Interaction completed.', 'success')
    end
end)