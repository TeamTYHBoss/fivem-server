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