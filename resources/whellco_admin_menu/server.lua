local QBCore = exports['qb-core']:GetCoreObject()

local actionCooldowns = {}

local function isAdmin(Player)
    local job = Player.PlayerData.job

    return job and Config.AdminJobs[job.name]
end

local function canAct(source)
    local now = os.time()

    if now - (actionCooldowns[source] or 0) < Config.ActionCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before using another admin action.', 'error')
        return false
    end

    actionCooldowns[source] = now

    return true
end

local function logAction(adminCitizenid, targetCitizenid, action, details)
    MySQL.query.await(
        [[INSERT INTO whellco_admin_menu_actions
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

RegisterNetEvent('whellco_admin_menu:action', function(action, targetSource, value)
    local source = source
    local Admin = QBCore.Functions.GetPlayer(source)
    local Target = QBCore.Functions.GetPlayer(tonumber(targetSource) or 0)

    if not Admin or not isAdmin(Admin) or not canAct(source) then
        return
    end

    if action == 'godmode' then
        TriggerClientEvent('whellco_admin_menu:godmode', source, value == true)
        logAction(Admin.PlayerData.citizenid, Admin.PlayerData.citizenid, 'godmode', { enabled = value })

    elseif action == 'invisibility' then
        TriggerClientEvent('whellco_admin_menu:invisibility', source, value == true)
        logAction(Admin.PlayerData.citizenid, Admin.PlayerData.citizenid, 'invisibility', { enabled = value })

    elseif action == 'noclip' then
        TriggerClientEvent('whellco_admin_menu:noclip', source, value == true)
        logAction(Admin.PlayerData.citizenid, Admin.PlayerData.citizenid, 'noclip', { enabled = value })

    elseif action == 'teleport' and Target then
        local adminPed = GetPlayerPed(source)
        local targetPed = GetPlayerPed(Target.PlayerData.source)
        local coords = GetEntityCoords(targetPed)

        SetEntityCoords(adminPed, coords.x, coords.y, coords.z, false, false, false, false)
        logAction(Admin.PlayerData.citizenid, Target.PlayerData.citizenid, 'teleport_to_player', {})

    elseif action == 'heal' and Target then
        TriggerClientEvent('whellco_admin_menu:heal', Target.PlayerData.source)
        logAction(Admin.PlayerData.citizenid, Target.PlayerData.citizenid, 'heal', {})

    elseif action == 'revive' and Target then
        TriggerClientEvent('whellco_admin_menu:revive', Target.PlayerData.source)
        logAction(Admin.PlayerData.citizenid, Target.PlayerData.citizenid, 'revive', {})

    elseif action == 'freeze' and Target then
        TriggerClientEvent('whellco_admin_menu:freeze', Target.PlayerData.source, value == true)
        logAction(Admin.PlayerData.citizenid, Target.PlayerData.citizenid, 'freeze', { enabled = value })

    elseif action == 'inventory' and Target then
        local inventory = Target.PlayerData.items or {}

        TriggerClientEvent('whellco_admin_menu:inventory', source, {
            targetName = Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname,
            inventory = inventory
        })

        logAction(Admin.PlayerData.citizenid, Target.PlayerData.citizenid, 'inventory_view', {})

    elseif action == 'warn' and Target then
        local reason = tostring(value or 'No reason provided')

        if #reason > Config.Moderation.MaxWarningReasonLength then
            reason = reason:sub(1, Config.Moderation.MaxWarningReasonLength)
        end

        TriggerClientEvent('whellco_admin_menu:warned', Target.PlayerData.source, {
            reason = reason,
            adminName = Admin.PlayerData.charinfo.firstname .. ' ' .. Admin.PlayerData.charinfo.lastname
        })

        logAction(Admin.PlayerData.citizenid, Target.PlayerData.citizenid, 'warn', { reason = reason })

    elseif action == 'kick' and Target then
        local reason = tostring(value or 'Kicked by staff')

        if #reason > Config.Moderation.MaxKickReasonLength then
            reason = reason:sub(1, Config.Moderation.MaxKickReasonLength)
        end

        logAction(Admin.PlayerData.citizenid, Target.PlayerData.citizenid, 'kick', { reason = reason })

        DropPlayer(Target.PlayerData.source, ('Kicked by staff: %s'):format(reason))
    end
end)

RegisterCommand(Config.MenuCommand, function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isAdmin(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not authorised to use the admin menu.', 'error')
        return
    end

    TriggerClientEvent('whellco_admin_menu:open', source)
end, false)