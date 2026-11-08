local QBCore = exports['qb-core']:GetCoreObject()

local dispatchCooldowns = {}
local repairCooldowns = {}

local function getMechanics()
    local players = QBCore.Functions.GetQBCorePlayers()
    local mechanics = {}

    for _, Player in pairs(players) do
        local job = Player.PlayerData.job

        if job and job.name == Config.MechanicJob then
            mechanics[#mechanics + 1] = Player.PlayerData.source
        end
    end

    return mechanics
end

local function dispatchMechanic(data)
    local mechanics = getMechanics()

    if #mechanics == 0 then
        return false
    end

    for _, mechanicSource in ipairs(mechanics) do
        TriggerClientEvent('whellco_mechanic_dispatch:dispatch', mechanicSource, data)
    end

    return true
end

RegisterNetEvent('whellco_mechanic_dispatch:request', function(coords, repairType, reason)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local repair = Config.RepairTypes[repairType]

    if not Player or not repair then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid repair type.', 'error')
        return
    end

    local now = os.time()

    if now - (dispatchCooldowns[source] or 0) < Config.DispatchCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before requesting another mechanic.', 'error')
        return
    end

    dispatchCooldowns[source] = now

    local dispatched = dispatchMechanic({
        requesterSource = source,
        requesterName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        coords = coords,
        repairType = repairType,
        repairLabel = repair.label,
        reason = reason or repair.label
    })

    if dispatched then
        TriggerClientEvent('QBCore:Notify', source, 'Mechanic dispatched.', 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, 'No mechanics are available.', 'error')
    end
end)

RegisterNetEvent('whellco_mechanic_dispatch:repair', function(targetSource, repairType)
    local source = source
    local Mechanic = QBCore.Functions.GetPlayer(source)
    local Target = QBCore.Functions.GetPlayer(tonumber(targetSource) or 0)
    local repair = Config.RepairTypes[repairType]

    if not Mechanic or not Target or not repair then
        return
    end

    local job = Mechanic.PlayerData.job

    if not job or job.name ~= Config.MechanicJob then
        TriggerClientEvent('QBCore:Notify', source, 'You are not a mechanic.', 'error')
        return
    end

    local now = os.time()

    if now - (repairCooldowns[source] or 0) < Config.RepairCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before performing another repair.', 'error')
        return
    end

    if Target.Functions.GetMoney('cash') < repair.price then
        TriggerClientEvent('QBCore:Notify', source, 'Customer does not have enough cash.', 'error')
        return
    end

    Target.Functions.RemoveMoney('cash', repair.price, ('Roadside repair: %s'):format(repairType))
    Mechanic.Functions.AddMoney('bank', math.floor(repair.price * 0.7), ('Roadside repair payment: %s'):format(repairType))

    repairCooldowns[source] = now

    TriggerClientEvent('whellco_mechanic_dispatch:repairStarted', Target.PlayerData.source, {
        repairType = repairType,
        label = repair.label,
        duration = repair.duration
    })

    TriggerClientEvent('whellco_mechanic_dispatch:repairStarted', source, {
        customerSource = Target.PlayerData.source,
        repairType = repairType,
        label = repair.label
    })
end)

RegisterCommand('callmechanic', function(source, args)
    local repairType = args[1]
    local reason = table.concat(args, ' ', 2)
    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if not repairType then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /callmechanic [repair_type] [reason]', 'error')
        return
    end

    TriggerEvent('whellco_mechanic_dispatch:request', coords, repairType, reason)
end, false)

RegisterCommand('repairvehicle', function(source, args)
    local targetSource = args[1]
    local repairType = args[2]

    if not targetSource or not repairType then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /repairvehicle [player_id] [repair_type]', 'error')
        return
    end

    TriggerEvent('whellco_mechanic_dispatch:repair', targetSource, repairType)
end, false)

RegisterCommand('mechanicinfo', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local names = {}

    for repairType, repair in pairs(Config.RepairTypes) do
        names[#names + 1] = ('%s - %s ($%d)'):format(repairType, repair.label, repair.price)
    end

    TriggerClientEvent('QBCore:Notify', source, table.concat(names, ', '), 'primary')
end, false)