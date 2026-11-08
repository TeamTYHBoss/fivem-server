local QBCore = exports['qb-core']:GetCoreObject()

local lockdownActive = false

RegisterNetEvent('whellco_emergency_lockdown:state', function(data)
    if not data then
        return
    end

    lockdownActive = data.active

    if lockdownActive then
        QBCore.Functions.Notify('Emergency lockdown active. Club doors are secured.', 'error', 10000)
    else
        QBCore.Functions.Notify('Emergency lockdown deactivated.', 'success')
    end
end)

RegisterCommand('lockdowninfo', function()
    QBCore.Functions.Notify(lockdownActive and 'Emergency lockdown is active.' or 'Emergency lockdown is inactive.', 'primary')
end, false)