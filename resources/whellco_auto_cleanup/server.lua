local QBCore = exports['qb-core']:GetCoreObject()

local cleanupCooldowns = {}

local function isAdmin(Player)
    local job = Player.PlayerData.job

    return job and Config.AdminJobs[job.name]
end

local function isExemptZone(coords)
    for _, zone in ipairs(Config.ExemptZones) do
        if #(coords - zone.coords) <= zone.radius then
            return true
        end
    end

    return false
end

RegisterNetEvent('whellco_auto_cleanup:report', function(data)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isAdmin(Player) then
        return
    end

    local now = os.time()

    if now - (cleanupCooldowns[source] or 0) < 10 then
        return
    end

    cleanupCooldowns[source] = now

    local vehicles = tonumber(data.vehicles) or 0
    local peds = tonumber(data.peds) or 0

    MySQL.query.await(
        [[INSERT INTO whellco_cleanup_logs
            (admin_citizenid, vehicles_cleaned, peds_cleaned)
          VALUES (?, ?, ?)]],
        {
            Player.PlayerData.citizenid,
            vehicles,
            peds
        }
    )

    TriggerClientEvent('QBCore:Notify', source, ('Cleanup complete: %d vehicles, %d peds.'):format(vehicles, peds), 'success')
end)

RegisterCommand('cleanupnow', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isAdmin(Player) then
        return
    end

    TriggerClientEvent('whellco_auto_cleanup:run', source)
end, false)

RegisterCommand('cleanupinfo', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isAdmin(Player) then
        return
    end

    TriggerClientEvent('QBCore:Notify', source, 'Auto-cleanup is active.', 'primary')
end, false)