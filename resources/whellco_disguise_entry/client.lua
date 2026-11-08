local QBCore = exports['qb-core']:GetCoreObject()

local disguiseActive = false
local currentArea = nil
local guardPromptActive = false
local suspicion = 0
local crowdBlending = false

local function isInsideArea(area)
    local playerCoords = GetEntityCoords(PlayerPedId())

    return #(playerCoords - area.coords) <= area.radius
end

local function getNearbyPeds()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local nearbyPeds = {}

    local handle, ped = FindFirstPed()

    repeat
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
            local distance = #(playerCoords - GetEntityCoords(ped))

            if distance <= Config.Disguise.CrowdBlendRadius then
                nearbyPeds[#nearbyPeds + 1] = ped
            end
        end

        _, ped = FindNextPed(handle)
    until not FindNextPed(handle)

    EndFindPed(handle)

    return nearbyPeds
end

local function isBlendingIntoCrowd()
    local playerPed = PlayerPedId()
    local playerSpeed = GetEntitySpeed(playerPed)

    if playerSpeed > Config.Disguise.CrowdBlendMaxSpeed then
        return false
    end

    return #getNearbyPeds() >= Config.Disguise.CrowdBlendMinimumPeds
end

local function makePedsReact()
    local playerPed = PlayerPedId()
    local nearbyPeds = getNearbyPeds()

    for _, ped in ipairs(nearbyPeds) do
        if DoesEntityExist(ped) then
            TaskLookAtEntity(ped, playerPed, 3000, 2048, 3)
            TaskTurnPedToFaceEntity(ped, playerPed, 2000)
        end
    end
end

local function updateSuspicionHud()
    SendNUIMessage({
        action = 'suspicion',
        value = suspicion,
        blending = crowdBlending
    })
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
    suspicion = 0
    crowdBlending = false

    local playerPed = PlayerPedId()

    SetPedComponentVariation(playerPed, 11, data.disguise.drawable, data.disguise.texture, 0)

    CreateThread(function()
        while disguiseActive do
            Wait(1000)

            local wasBlending = crowdBlending
            crowdBlending = isBlendingIntoCrowd()

            if crowdBlending then
                updateSuspicionHud()
            else
                if wasBlending then
                    makePedsReact()
                end

                suspicion = math.min(Config.Disguise.SuspicionMax, suspicion + Config.Disguise.SuspicionPerSecond)
                updateSuspicionHud()
            end

            if suspicion >= Config.Disguise.SuspicionMax then
                disguiseActive = false
                TriggerServerEvent('whellco_disguise_entry:detect')
                break
            end

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

            if math.random(100) <= Config.Disguise.GuardChallengeChance then
                TriggerServerEvent('whellco_disguise_entry:guardChallenge')
            end
        end
    end)
end)

RegisterNetEvent('whellco_disguise_entry:guardPrompt', function()
    guardPromptActive = true

    local response = nil

    CreateThread(function()
        while guardPromptActive do
            Wait(0)

            SetTextComponentFormat('STRING')
            AddTextComponentString('Guard: "State your business." Press [E] to convince them.')
            DisplayHelpTextThisFrame(false, false)

            if IsControlJustReleased(0, 38) then
                response = 'convince'
                break
            end
        end
    end)

    Wait(5000)

    guardPromptActive = false

    if response then
        suspicion = math.max(0, suspicion - 25)
        updateSuspicionHud()
        TriggerServerEvent('whellco_disguise_entry:guardResponse', response)
    else
        TriggerServerEvent('whellco_disguise_entry:guardResponse', 'fail')
    end
end)

RegisterNetEvent('whellco_disguise_entry:remove', function()
    disguiseActive = false
    currentArea = nil
    guardPromptActive = false
    suspicion = 0
    crowdBlending = false

    SendNUIMessage({ action = 'suspicion', value = 0, blending = false })
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
    QBCore.Functions.Notify('Stand in a restricted area and press E to use a disguise kit. Move slowly in crowds to pause suspicion growth.', 'primary')
end, false)