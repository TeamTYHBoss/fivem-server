local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand('appealinfo', function()
    QBCore.Functions.Notify(
        'Use /appealfine [fine_id] [reason] to appeal. Use /startservice [appeal_id] and /doservice for community service.',
        'primary'
    )
end, false)