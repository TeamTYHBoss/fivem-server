local QBCore = exports['qb-core']:GetCoreObject()

local dispatchCooldowns = {}

local function getTowDrivers()
    local players = QBCore.Functions.GetQBCorePlayers()
    local drivers = {}

    for _, Player in pairs(players) do
        local job = Player.PlayerData.job

        if job and job.name == Config.TowJob then
            drivers[#drivers + 1] = Player.PlayerData.source
        end
    end

    return drivers
end

local function dispatchTow(data)
    local drivers = getTowDrivers()

    if #drivers == 0 then
        return false
    end

    for _, driverSource in ipairs(drivers) do
        TriggerClientEvent('whellco_tow_dispatch:dispatch', driverSource, data)
    end

    return true
end

RegisterNetEvent('whellco_tow_dispatch:request', function(coords, reason)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local now = os.time()

    if now - (dispatchCooldowns[source] or 0) < Config.DispatchCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before requesting another tow.', 'error')
        return
    end

    dispatchCooldowns[source] = now

    local dispatched = dispatchTow({
        requesterSource = source,
        requesterName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        coords = coords,
        reason = reason or 'Vehicle recovery requested'
    })

    if dispatched then
        TriggerClientEvent('QBCore:Notify', source, 'Tow truck dispatched.', 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, 'No tow drivers are available.', 'error')
    end
end)

RegisterNetEvent('whellco_impound_lot:vehicleImpounded', function(data)
    if not Config.AutoDispatchOnImpound or not data or not data.coords then
        return
    end

    dispatchTow({
        requesterSource = data.ownerSource,
        requesterName = data.ownerName or 'Unknown',
        coords = data.coords,
        reason = ('Automatic tow dispatch: %s'):format(data.reason or 'Vehicle impounded')
    })
end)

RegisterCommand('requesttow', function(source, args)
    local reason = table.concat(args, ' ')
    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    TriggerEvent('whellco_tow_dispatch:request', coords, reason)
end, false)

RegisterCommand('towdrivers', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local drivers = getTowDrivers()

    TriggerClientEvent('QBCore:Notify', source, ('%d tow driver(s) available.'):format(#drivers), 'primary')
end, false)