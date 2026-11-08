local QBCore = exports['qb-core']:GetCoreObject()

local commandCooldowns = {}

local function hasPermission(Player, permission)
    local job = Player.PlayerData.job

    if not job or not Config.AdminPermissions[permission] then
        return false
    end

    for _, allowedJob in ipairs(Config.AdminPermissions[permission]) do
        if job.name == allowedJob then
            return true
        end
    end

    return false
end

local function logAction(adminCitizenid, targetCitizenid, action, details)
    MySQL.query.await(
        [[INSERT INTO whellco_admin_actions
            (admin_citizenid, target_citizenid, action, details)
          VALUES (?, ?, ?, ?)]],
        {
            adminCitizenid,
            targetCitizenid or 'none',
            action,
            json.encode(details or {})
        }
    )
end

local function canUseCommand(source)
    local now = os.time()

    if now - (commandCooldowns[source] or 0) < Config.CommandCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before using another admin command.', 'error')
        return false
    end

    commandCooldowns[source] = now

    return true
end

RegisterCommand('adminmode', function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not hasPermission(Player, 'godmode') or not canUseCommand(source) then
        return
    end

    local enabled = args[1] == 'on'

    TriggerClientEvent('whellco_admin_toolkit:godmode', source, enabled)
    logAction(Player.PlayerData.citizenid, Player.PlayerData.citizenid, 'godmode', { enabled = enabled })
end, false)

RegisterCommand('admininvisible', function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not hasPermission(Player, 'invisibility') or not canUseCommand(source) then
        return
    end

    local enabled = args[1] == 'on'

    TriggerClientEvent('whellco_admin_toolkit:invisibility', source, enabled)
    logAction(Player.PlayerData.citizenid, Player.PlayerData.citizenid, 'invisibility', { enabled = enabled })
end, false)

RegisterCommand('admintp', function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not hasPermission(Player, 'teleport') or not canUseCommand(source) then
        return
    end

    local x = tonumber(args[1])
    local y = tonumber(args[2])
    local z = tonumber(args[3])

    if not x or not y or not z then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /admintp [x] [y] [z]', 'error')
        return
    end

    TriggerClientEvent('whellco_admin_toolkit:teleport', source, vector3(x, y, z))
    logAction(Player.PlayerData.citizenid, Player.PlayerData.citizenid, 'teleport', { x = x, y = y, z = z })
end, false)

RegisterCommand('admininv', function(source, args)
    local Admin = QBCore.Functions.GetPlayer(source)
    local Target = QBCore.Functions.GetPlayer(tonumber(args[1]) or 0)

    if not Admin or not Target or not hasPermission(Admin, 'inventory') or not canUseCommand(source) then
        return
    end

    local inventory = Target.PlayerData.items or {}

    TriggerClientEvent('whellco_admin_toolkit:inventory', source, {
        targetName = Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname,
        inventory = inventory
    })

    logAction(Admin.PlayerData.citizenid, Target.PlayerData.citizenid, 'inventory_view', {})
end, false)

RegisterCommand('adminheal', function(source, args)
    local Admin = QBCore.Functions.GetPlayer(source)
    local Target = QBCore.Functions.GetPlayer(tonumber(args[1]) or 0)

    if not Admin or not Target or not hasPermission(Admin, 'heal') or not canUseCommand(source) then
        return
    end

    TriggerClientEvent('whellco_admin_toolkit:heal', Target.PlayerData.source)
    logAction(Admin.PlayerData.citizenid, Target.PlayerData.citizenid, 'heal', {})
end, false)

RegisterCommand('adminrevive', function(source, args)
    local Admin = QBCore.Functions.GetPlayer(source)
    local Target = QBCore.Functions.GetPlayer(tonumber(args[1]) or 0)

    if not Admin or not Target or not hasPermission(Admin, 'revive') or not canUseCommand(source) then
        return
    end

    TriggerClientEvent('whellco_admin_toolkit:revive', Target.PlayerData.source)
    logAction(Admin.PlayerData.citizenid, Target.PlayerData.citizenid, 'revive', {})
end, false)

RegisterCommand('adminfreeze', function(source, args)
    local Admin = QBCore.Functions.GetPlayer(source)
    local Target = QBCore.Functions.GetPlayer(tonumber(args[1]) or 0)

    if not Admin or not Target or not hasPermission(Admin, 'freeze') or not canUseCommand(source) then
        return
    end

    local enabled = args[2] == 'on'

    TriggerClientEvent('whellco_admin_toolkit:freeze', Target.PlayerData.source, enabled)
    logAction(Admin.PlayerData.citizenid, Target.PlayerData.citizenid, 'freeze', { enabled = enabled })
end, false)

RegisterCommand('adminhelp', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not hasPermission(Player, 'teleport') then
        return
    end

    TriggerClientEvent('QBCore:Notify', source, 'Admin commands: /adminmode, /admininvisible, /admintp, /admininv, /adminheal, /adminrevive, /adminfreeze.', 'primary')
end, false)