local QBCore = exports['qb-core']:GetCoreObject()

local robberyActive = false
local currentTarget = nil

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
    currentTarget = targetServerId

    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'start' })
end)

RegisterNetEvent('whellco_player_robbery:victim', function(robberServerId)
    QBCore.Functions.Notify('Someone is attempting to rob you.', 'error', 10000)
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
    QBCore.Functions.Notify('Walk up to another player and press E to start a robbery.', 'primary')
end, false)