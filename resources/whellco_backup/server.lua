local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand('whellcobackup', function(source)
    if source > 0 then
        local Player = QBCore.Functions.GetPlayer(source)

        if not Player or not QBCore.Functions.HasPermission(source, 'admin') then
            return
        end
    end

    print('[WhellCo Backup] Backup request received.')
end, false)