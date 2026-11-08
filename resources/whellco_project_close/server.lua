local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand('whellcoprojectclose', function(source)
    if source > 0 then
        local Player = QBCore.Functions.GetPlayer(source)

        if not Player or not QBCore.Functions.HasPermission(source, 'admin') then
            return
        end
    end

    print('[WhellCo Project Close] Project close check complete.')
end, false)