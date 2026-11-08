local QBCore = exports['qb-core']:GetCoreObject()

local activeContract = nil
local contractBlips = {}
local contractPeds = {}

local function clearContract()
    activeContract = nil

    for _, blip in ipairs(contractBlips) do
        RemoveBlip(blip)
    end

    contractBlips = {}

    for _, ped in ipairs(contractPeds) do
        if DoesEntityExist(ped) then
            DeletePed(ped)
        end
    end

    contractPeds = {}
end

RegisterNetEvent('whellco_hitman:applyAppearance', function(appearance)
    if not appearance then
        return
    end

    local playerPed = PlayerPedId()

    SetPedComponentVariation(playerPed, 11, appearance.HitmanSkin.drawable, appearance.HitmanSkin.texture, 0)

    if appearance.NeckBarcode then
        ClearPedDecorations(playerPed)
        AddPedDecorationFromHashes(
            playerPed,
            GetHashKey(appearance.NeckBarcode.tattooCollection),
            GetHashKey(appearance.NeckBarcode.tattooName)
        )
    end

    QBCore.Functions.Notify('Hitman appearance applied.', 'success')
end)

RegisterNetEvent('whellco_hitman:start', function(data)
    clearContract()
    activeContract = data

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for index = 1, data.npcCount do
        local offset = vector3(math.random(-80, 80), math.random(-80, 80), 0)
        local spawnCoords = playerCoords + offset
        local ped = CreatePed(4, GetHashKey(Config.Hitman.NpcTargetModel), spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, true)

        if ped and ped ~= 0 then
            SetEntityAsMissionEntity(ped, true, true)
            SetPedArmour(ped, data.npcArmour)
            SetPedAccuracy(ped, 25)
            GiveWeaponToPed(ped, GetHashKey(data.npcWeapon), 100, false, true)
            TaskCombatPed(ped, playerPed, 0, 16)

            contractPeds[#contractPeds + 1] = ped

            local blip = AddBlipForEntity(ped)
            SetBlipSprite(blip, 161)
            SetBlipColour(blip, 1)
            SetBlipAsShortRange(blip, false)

            contractBlips[#contractBlips + 1] = blip
        end
    end

    CreateThread(function()
        while activeContract do
            Wait(1000)

            local timeLeft = activeContract.expiresAt - os.time()

            if timeLeft <= 0 then
                QBCore.Functions.Notify('Contract expired.', 'error')
                TriggerServerEvent('whellco_hitman:complete', false)
                clearContract()
                break
            end

            local remainingTargets = 0

            for _, ped in ipairs(contractPeds) do
                if DoesEntityExist(ped) and not IsEntityDead(ped) then
                    remainingTargets = remainingTargets + 1
                end
            end

            if remainingTargets == 0 then
                TriggerServerEvent('whellco_hitman:complete', true)
                clearContract()
                break
            end
        end
    end)
end)

RegisterNetEvent('whellco_hitman:openMenu', function()
    QBCore.Functions.Notify('Use /hitman to accept a contract.', 'primary')
end)

RegisterCommand('hitmanhelp', function()
    QBCore.Functions.Notify('Use /hitman to accept a contract. Contracts escalate in difficulty and payout.', 'primary')
end, false)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    clearContract()
end)