local playerJobs = {}
local jobProgress = {}
local lastInteraction = {}

local function canInteract(source)
    if type(source) ~= 'number' or source <= 0 then
        return false
    end

    local now = GetGameTimer()

    if now - (lastInteraction[source] or 0) < 2000 then
        return false
    end

    lastInteraction[source] = now

    return true
end

local function getNearbyInteraction(source, interaction)
    local ped = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(ped)

    return #(playerCoords - interaction.coords) <= 5.0
end

local function getTier(completedJobs)
    local selectedTier = Config.JobTiers[1]

    for _, tier in ipairs(Config.JobTiers) do
        if completedJobs >= tier.minimumCompleted then
            selectedTier = tier
        end
    end

    return selectedTier
end

local function buildRoute(job, tier)
    local stops = {}
    local used = {}

    for index = 1, tier.stops do
        local destinationIndex

        repeat
            destinationIndex = math.random(1, #Config.JobDestinations)
        until not used[destinationIndex]

        used[destinationIndex] = true

        stops[index] = {
            index = index,
            coords = Config.JobDestinations[destinationIndex]
        }
    end

    local payout = job.basePayout + (job.payoutIncreasePerTier * (tier.stops - 1))

    return {
        stops = stops,
        payout = payout,
        timeLimit = tier.timeLimit
    }
end

RegisterNetEvent('whellco_immersion:interact', function(interactionType, interaction)
    local source = source

    if not canInteract(source) then
        return
    end

    if type(interactionType) ~= 'string' or type(interaction) ~= 'table' then
        return
    end

    if not getNearbyInteraction(source, interaction) then
        return
    end

    if interactionType == 'job' then
        local job = Config.Jobs[interaction.jobId]

        if job and not playerJobs[source] then
            local completedJobs = jobProgress[source] or 0
            local tier = getTier(completedJobs)
            local mission = buildRoute(job, tier)

            playerJobs[source] = {
                jobId = interaction.jobId,
                mission = mission,
                currentStop = 1,
                startedAt = GetGameTimer()
            }

            TriggerClientEvent('whellco_immersion:startJob', source, interaction.jobId, job.vehicle, mission)
        end

    elseif interactionType == 'shop' then
        local shop = Config.Shops[interaction.shopId]

        if shop then
            TriggerClientEvent('whellco_immersion:notify', source, ('%s is available. Use the shop menu in a future update.'):format(shop.label))
        end

    elseif interactionType == 'transport' then
        local stop = Config.Transport[interaction.stopId]

        if stop then
            TriggerClientEvent('whellco_immersion:notify', source, ('Public transport available from %s.'):format(stop.label))
            TriggerClientEvent('whellco_immersion:teleport', source, stop.destinations.paleto.coords)
        end

    elseif interactionType == 'service' then
        local service = Config.Services[interaction.serviceId]

        if service then
            TriggerClientEvent('whellco_immersion:notify', source, ('Welcome to %s.'):format(service.label))
        end

    elseif interactionType == 'fuel' then
        local station = Config.FuelStations[interaction.stationIndex]

        if station then
            TriggerClientEvent('whellco_immersion:notify', source, ('Fuel available at %s for %s%.2f per litre.'):format(station.label, Config.Currency, station.pricePerLitre / 100))
        end
    end
end)

RegisterNetEvent('whellco_immersion:completeStop', function()
    local source = source
    local activeJob = playerJobs[source]

    if not activeJob then
        return
    end

    if GetGameTimer() - activeJob.startedAt > activeJob.mission.timeLimit * 1000 then
        playerJobs[source] = nil

        TriggerClientEvent('whellco_immersion:notify', source, 'You ran out of time. Return to the job centre to try again.')
        return
    end

    if activeJob.currentStop < #activeJob.mission.stops then
        activeJob.currentStop = activeJob.currentStop + 1

        TriggerClientEvent('whellco_immersion:nextStop', source, activeJob.mission.stops[activeJob.currentStop])
        return
    end

    local jobId = activeJob.jobId
    local payout = activeJob.mission.payout

    jobProgress[source] = (jobProgress[source] or 0) + 1
    playerJobs[source] = nil

    -- Replace with your economy framework's server-side money addition.
    TriggerClientEvent('whellco_immersion:completeJob', source, ('Job complete. You earned %s%d.'):format(Config.Currency, payout))
end)

AddEventHandler('playerDropped', function()
    playerJobs[source] = nil
    lastInteraction[source] = nil
end)
