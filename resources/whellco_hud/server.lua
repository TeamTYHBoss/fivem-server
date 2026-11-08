local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand('hudsave', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    TriggerClientEvent('QBCore:Notify', source, 'HUD preferences saved.', 'success')
end, false)