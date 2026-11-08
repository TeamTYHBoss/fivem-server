local QBCore = exports['qb-core']:GetCoreObject()

local currentFacility = nil

RegisterNetEvent('whellco_jail:teleport', function(data)
    if not data or not data.coords then
        return
    end

    local playerPed = PlayerPedId()

    SetEntityCoords(playerPed, data.coords.x, data.coords.y, data.coords.z, false, false, false, false)
    currentFacility = data.facility

    QBCore.Functions.Notify(
        ('Incarcerated at %s for %d minute(s). Reason: %s'):format(
            data.facility == 'prison' and 'prison' or 'jail',
            data.minutes or 0,
            data.reason or 'No reason provided'
        ),
        'error'
    )
end)

RegisterNetEvent('whellco_jail:release', function(data)
    local playerPed = PlayerPedId()
    local coords = data.facility == 'prison' and Config.Prison.release or Config.Jail.release

    SetEntityCoords(playerPed, coords.x, coords.y, coords.z, false, false, false, false)
    currentFacility = nil

    QBCore.Functions.Notify('You have been released.', 'success')
end)

RegisterCommand('jailjob', function(_, args)
    local jobIndex = tonumber(args[1])

    if not jobIndex then
        QBCore.Functions.Notify('Usage: /jailjob [job_index]', 'error')
        return
    end

    TriggerServerEvent('whellco_jail:completeJob', jobIndex)
end, false)