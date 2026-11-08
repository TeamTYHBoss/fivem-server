local QBCore = exports['qb-core']:GetCoreObject()

local isViewing = false
local cameraIndex = 0

RegisterNetEvent('whellco_cctv_monitoring:view', function(camera)
    if not camera then
        return
    end

    isViewing = true
    cameraIndex = cameraIndex + 1

    QBCore.Functions.Notify(
        ('Viewing %s'):format(camera.label),
        'primary'
    )
end)

RegisterCommand('cctvinfo', function()
    QBCore.Functions.Notify('Use /cctv [camera_id] to view CCTV cameras.', 'primary')
end, false)