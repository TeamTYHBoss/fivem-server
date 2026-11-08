local activeNpc = nil

RegisterNetEvent('whellco_ai_dialogue:receive', function(data)
    if not data or not data.message then
        return
    end

    QBCore.Functions.Notify(('%s: %s'):format(data.npcLabel or 'NPC', data.message), 'primary', 7000)
end)

RegisterCommand('aitalk', function(_, args)
    local message = table.concat(args, ' ')

    if not activeNpc or #message == 0 then
        QBCore.Functions.Notify('Stand near an AI NPC and use: /aitalk [message]', 'error')
        return
    end

    TriggerServerEvent('whellco_ai_dialogue:send', activeNpc, message)
end, false)

RegisterCommand('aiclear', function()
    activeNpc = nil
    QBCore.Functions.Notify('AI dialogue target cleared.', 'success')
end, false)

CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

        for npcId, npc in pairs(Config.AllowedNpcs) do
            local distance = #(coords - npc.coords)

            if distance < 3.0 then
                activeNpc = npcId
                sleep = 500
                break
            end
        end

        Wait(sleep)
    end
end)