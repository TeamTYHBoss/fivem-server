local QBCore = exports['qb-core']:GetCoreObject()

local viewCooldowns = {}

local function isManager(Player)
    local job = Player.PlayerData.job

    return job and job.name == Config.ManagerJob
end

RegisterNetEvent('whellco_cctv_monitoring:view', function(cameraIndex)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isManager(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not authorised to view CCTV.', 'error')
        return
    end

    local now = os.time()

    if now - (viewCooldowns[source] or 0) < Config.ViewCooldownSeconds then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before viewing another camera.', 'error')
        return
    end

    local camera = Config.Cameras[tonumber(cameraIndex) or 0]

    if not camera then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid camera selected.', 'error')
        return
    end

    viewCooldowns[source] = now

    TriggerClientEvent('whellco_cctv_monitoring:view', source, {
        label = camera.label,
        position = camera.position,
        rotation = camera.rotation,
        fov = camera.fov
    })
end)

RegisterCommand('cctv', function(source, args)
    local cameraIndex = args[1]

    if not cameraIndex then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /cctv [camera_id]', 'error')
        return
    end

    TriggerEvent('whellco_cctv_monitoring:view', cameraIndex)
end, false)