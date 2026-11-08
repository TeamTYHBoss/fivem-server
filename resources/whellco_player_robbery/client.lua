local QBCore = exports['qb-core']:GetCoreObject()

local robberyActive = false
local handsUp = false

local function getClosestPlayer()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestPlayer = nil
    local closestDistance = Config.Robbery.MaxDistance

    for _, playerId in ipairs(GetActivePlayers()) do
        local targetPed = GetPlayerPed(playerId)
        local distance = #(playerCoords - GetEntityCoords(targetPed))

        if distance < closestDistance then
            closestPlayer = playerId
            closestDistance = distance
        end
    end

    return closestPlayer
end

CreateThread(function()
    while true do
        Wait(0)

        if IsControlJustPressed(0, 73) then
            handsUp = not handsUp

            if handsUp then
                TaskHandsUp(PlayerPedId(), 10000, PlayerPedId(), -1, true)
            else
                ClearPedTasks(PlayerPedId())
            end

            TriggerServerEvent('whellco_player_robbery:handsUp', handsUp)
        end

        if not robberyActive then
            local target = getClosestPlayer()

            if target then
                if IsControlJustReleased(0, 38) then
                    local targetServerId = GetPlayerServerId(target)

                    TriggerServerEvent('whellco_player_robbery:start', targetServerId)
                end
            end
        end
    end
end)

RegisterNetEvent('whellco_player_robbery:start', function(targetServerId)
    robberyActive = true

    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'start' })
end)

RegisterNetEvent('whellco_player_robbery:victim', function(robberServerId)
    QBCore.Functions.Notify('Someone is attempting to rob you. Keep your hands up!', 'error', 10000)
    PlaySoundFrontend(-1, 'CHECKPOINT_PERFECT', 'HUD_MINI_GAME_SOUNDSET', true)
end)

RegisterNetEvent('whellco_player_robbery:fail', function(reason)
    robberyActive = false

    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })

    if reason == 'target-lowered-hands' then
        QBCore.Functions.Notify('Robbery failed: the target lowered their hands.', 'error', 10000)
    else
        QBCore.Functions.Notify('Robbery failed.', 'error', 10000)
    end
end)

RegisterNetEvent('whellco_player_robbery:policeAlert', function(coords)
    if not coords then
        return
    end

    local playerCoords = GetEntityCoords(PlayerPedId())

    if #(playerCoords - coords) <= Config.Robbery.AlertPoliceRadius then
        QBCore.Functions.Notify('Robbery reported nearby.', 'error', 10000)
    end
end)

RegisterNUICallback('complete', function(data, cb)
    robberyActive = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })

    TriggerServerEvent('whellco_player_robbery:complete', data.success == true)
    cb('ok')
end)

RegisterCommand('robberyhelp', function()
    QBCore.Functions.Notify('Press X to put your hands up. Keep them up during a robbery or the robbery will fail.', 'primary')
end, false)