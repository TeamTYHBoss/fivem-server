local playerJobs = {}
local lastInteraction = {}

local function canInteract(source)
    if type(source) ~= 'number' or source <= 0 then
        return false
    end

    local now = os.time()

    if now - (lastInteraction[source] or 0) < 2 then
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

    if interactionType == 'shop' then
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

    elseif interactionType == 'job' then
        local job = Config.Jobs[interaction.jobId]

        if job and not playerJobs[source] then
            playerJobs[source] = interaction.jobId

            TriggerClientEvent('whellco_immersion:startJob', source, interaction.jobId, job.vehicle, vector3(195.2, -933.8, 30.7))
        end

    elseif interactionType == 'fuel' then
        local station = Config.FuelStations[interaction.stationIndex]

        if station then
            TriggerClientEvent('whellco_immersion:notify', source, ('Fuel available at %s for %s%.2f per litre.'):format(station.label, Config.Currency, station.pricePerLitre / 100))
        end
    end
end)

RegisterNetEvent('whellco_immersion:completeJob', function()
    local source = source
    local jobId = playerJobs[source]

    if not jobId then
        return
    end

    local job = Config.Jobs[jobId]

    if not job then
        return
    end

    local payout = job.payoutPerDelivery or job.payoutPerCollection or job.payoutPerRepair or 0

    -- Replace with your economy framework's server-side money addition.
    TriggerClientEvent('whellco_immersion:completeJob', source, ('Job complete. You earned %s%d.'):format(Config.Currency, payout))

    playerJobs[source] = nil
end)

AddEventHandler('playerDropped', function()
    playerJobs[source] = nil
    lastInteraction[source] = nil
end)
