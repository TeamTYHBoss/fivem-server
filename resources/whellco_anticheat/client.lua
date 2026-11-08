local QBCore = exports['qb-core']:GetCoreObject()

local lastPosition = nil

CreateThread(function()
    while true do
        Wait(5000)

        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

        if lastPosition then
            local distance = #(coords - lastPosition)

            if distance > 200.0 then
                TriggerServerEvent('whellco_anticheat:report', 'Teleport', {
                    distance = distance
                })
            end
        end

        lastPosition = coords
    end
end)

RegisterCommand('anticheatinfo', function()
    QBCore.Functions.Notify('Anti-cheat monitoring is active.', 'primary')
end, false)