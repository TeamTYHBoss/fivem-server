local QBCore = exports['qb-core']:GetCoreObject()

local function hasJobAccess(Player, interaction)
    if not interaction.requiredJob then
        return true
    end

    local job = Player.PlayerData.job

    return job and job.name == interaction.requiredJob and (job.grade.level or 0) >= (interaction.jobGrade or 0)
end

RegisterNetEvent('whellco_immersive_interiors:interact', function(interiorId, interactionId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local interactions = Config.Interactions[interiorId]

    if not interactions then
        return
    end

    for _, interaction in ipairs(interactions) do
        if interaction.id == interactionId then
            if not hasJobAccess(Player, interaction) then
                TriggerClientEvent('QBCore:Notify', source, 'You do not have access to this area.', 'error')
                return
            end

            TriggerClientEvent('whellco_immersive_interiors:notify', source, ('Opened %s.'):format(interaction.label), 'success')
            return
        end
    end
end)

RegisterNetEvent('whellco_immersive_interiors:teleport', function(interiorId, target)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not QBCore.Functions.HasPermission(source, 'admin') then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have permission.', 'error')
        return
    end

    local interior = Config.Interiors[interiorId]

    if not interior then
        TriggerClientEvent('QBCore:Notify', source, 'Interior not found.', 'error')
        return
    end

    local coords

    if target == 'exit' then
        coords = interior.exit
    else
        coords = interior.entry
    end

    TriggerClientEvent('whellco_immersive_interiors:teleport', source, {
        interiorId = interiorId,
        label = interior.label,
        coords = coords
    })
end)

RegisterCommand('interiors', function(source)
    if source > 0 then
        local Player = QBCore.Functions.GetPlayer(source)

        if not Player then
            return
        end

        local names = {}

        for id, interior in pairs(Config.Interiors) do
            names[#names + 1] = ('%s - %s'):format(id, interior.label)
        end

        TriggerClientEvent('QBCore:Notify', source, table.concat(names, ', '), 'primary')
    end
end, false)

RegisterCommand('interiortp', function(source, args)
    if source > 0 then
        local Player = QBCore.Functions.GetPlayer(source)

        if not Player or not QBCore.Functions.HasPermission(source, 'admin') then
            TriggerClientEvent('QBCore:Notify', source, 'You do not have permission.', 'error')
            return
        end
    end

    local interiorId = tostring(args[1] or '')
    local target = tostring(args[2] or 'entry')

    if not Config.Interiors[interiorId] then
        if source > 0 then
            TriggerClientEvent('QBCore:Notify', source, 'Invalid interior ID. Use /interiors to list them.', 'error')
        else
            print('Invalid interior ID. Use /interiors to list them.')
        end

        return
    end

    if target ~= 'entry' and target ~= 'exit' then
        target = 'entry'
    end

    TriggerClientEvent('whellco_immersive_interiors:teleport', source, {
        interiorId = interiorId,
        label = Config.Interiors[interiorId].label,
        coords = target == 'exit' and Config.Interiors[interiorId].exit or Config.Interiors[interiorId].entry
    })
end, false)