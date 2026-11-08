local QBCore = exports['qb-core']:GetCoreObject()

local hudVisible = true
local lastUpdate = 0

local function getHudData()
    local playerPed = PlayerPedId()
    local playerData = QBCore.Functions.GetPlayerData()
    local health = GetEntityHealth(playerPed)
    local maxHealth = GetEntityMaxHealth(playerPed)
    local armor = GetPedArmour(playerPed)
    local stamina = 100 - GetPlayerSprintStaminaRemaining(PlayerId())
    local underwater = IsPedSwimmingUnderWater(playerPed)
    local oxygen = underwater and GetPlayerUnderwaterTimeRemaining(PlayerId()) or 100

    return {
        health = math.floor((health / maxHealth) * 100),
        armor = armor,
        stamina = math.floor(stamina),
        hunger = playerData.metadata and playerData.metadata.hunger or 100,
        thirst = playerData.metadata and playerData.metadata.thirst or 100,
        stress = playerData.metadata and playerData.metadata.stress or 0,
        oxygen = math.floor(oxygen),
        voice = NetworkIsPlayerTalking(PlayerId())
    }
end

CreateThread(function()
    while true do
        local sleep = Config.UpdateInterval

        if hudVisible then
            local data = getHudData()

            SendNUIMessage({
                action = 'updateHud',
                data = data,
                config = Config.Hud
            })
        end

        Wait(sleep)
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    hudVisible = true
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    hudVisible = false
    SendNUIMessage({ action = 'hideHud' })
end)

RegisterCommand('hudtoggle', function()
    hudVisible = not hudVisible

    if hudVisible then
        QBCore.Functions.Notify('HUD enabled.', 'success')
    else
        SendNUIMessage({ action = 'hideHud' })
        QBCore.Functions.Notify('HUD disabled.', 'success')
    end
end, false)

RegisterCommand('hudlayout', function(_, args)
    local layout = args[1]

    if not Config.LayoutPresets[layout] then
        QBCore.Functions.Notify('Available layouts: default, compact', 'error')
        return
    end

    Config.Hud = Config.LayoutPresets[layout]
    QBCore.Functions.Notify(('HUD layout changed to %s.'):format(layout), 'success')
end, false)