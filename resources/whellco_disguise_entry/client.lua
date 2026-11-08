local QBCore = exports['qb-core']:GetCoreObject()

local disguiseActive = false
local currentArea = nil

local function isInsideArea(area)
    local playerCoords = GetEntityCoords(PlayerPedId())

    return #(playerCoords - area.coords) <= area.radius
end

CreateThread(function()
    while true do
        Wait(1000)

        if not disguiseActive then
            local playerCoords = GetEntityCoords(PlayerPedId())

            for _, area in ipairs(Config.RestrictedAreas) do
                if #(playerCoords - area.coords) <= area.radius then
                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent('whellco_disguise_entry:enter', area.name)
                    end

                    break
                end
            end
        end
    end
end)

RegisterNetEvent('whellco_disguise_entry:apply', function(data)
    disguiseActive = true
    currentArea = data.area

    local playerPed = PlayerPedId()

    SetPedComponentVariation(playerPed, 11, data.disguise.drawable, data.disguise.texture, 0)

    CreateThread(function()
        while disguiseActive do
            Wait(Config.Disguise.DetectionIntervalSeconds * 1000)

            if os.time() > data.expiresAt then
                disguiseActive = false
                TriggerServerEvent('whellco_disguise_entry:detect')
                break
            end

            if not isInsideArea(currentArea) then
                disguiseActive = false
                TriggerServerEvent('whellco_disguise_entry:detect')
                break
            end

            if math.random(100) <= Config.Disguise.DetectionChance then
                disguiseActive = false
                TriggerServerEvent('whellco_disguise_entry:detect')
                break
            end
        end
    end)
end)

RegisterNetEvent('whellco_disguise_entry:remove', function()
    disguiseActive = false
    currentArea = nil
end)

RegisterNetEvent('whellco_disguise_entry:alert', function(job, coords)
    local Player = QBCore.Functions.GetPlayer(PlayerId())

    if not Player then
        return
    end

    local job = Player.PlayerData.job

    if job and Config.Disguise.AlertJobs[job.name] then
        local playerCoords = GetEntityCoords(PlayerPedId())

        if #(playerCoords - coords) <= 200.0 then
            QBCore.Functions.Notify('Suspicious disguised entry detected nearby.', 'error', 10000)
        end
    end
end)

RegisterCommand('disguisehelp', function()
    QBCore.Functions.Notify('Stand in a restricted area and press E to use a disguise kit.', 'primary')
end, false)