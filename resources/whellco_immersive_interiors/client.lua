local QBCore = exports['qb-core']:GetCoreObject()

local currentInterior = nil
local loadedInteriors = {}
local lastTeleport = 0

local function requestInterior(name)
    if loadedInteriors[name] then
        return true
    end

    local interior = Config.Interiors[name]

    if not interior then
        return false
    end

    RequestCollisionAtCoord(interior.entry.x, interior.entry.y, interior.entry.z)

    local timeout = GetGameTimer() + 10000

    while not HasCollisionLoadedAroundEntity(PlayerPedId()) and GetGameTimer() < timeout do
        Wait(50)
    end

    loadedInteriors[name] = true

    return true
end

local function releaseInterior(name)
    if not loadedInteriors[name] then
        return
    end

    loadedInteriors[name] = nil
end

local function hasJobAccess(Player, interior)
    local requiredJob = interior.requiredJob

    if not requiredJob then
        return true
    end

    local job = Player.PlayerData.job

    return job and job.name == requiredJob and (job.grade.level or 0) >= (interior.jobGrade or 0)
end

local function hasInteractionAccess(Player, interaction)
    if not interaction.requiredJob then
        return true
    end

    local job = Player.PlayerData.job

    return job and job.name == interaction.requiredJob and (job.grade.level or 0) >= (interaction.jobGrade or 0)
end

local function playSound(soundName, soundSet)
    if not soundName or soundName == '' then
        return
    end

    PlaySoundFrontend(-1, soundName, soundSet or 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
end

local function playTeleportEffect(coords)
    if not Config.TeleportTransition.enabled then
        return
    end

    local effect = Config.TeleportTransition

    RequestNamedPtfxAsset(effect.particleEffect)

    local timeout = GetGameTimer() + 3000

    while not HasNamedPtfxAssetLoaded(effect.particleEffect) and GetGameTimer() < timeout do
        Wait(25)
    end

    if HasNamedPtfxAssetLoaded(effect.particleEffect) then
        UseParticleFxAssetNextCall(effect.particleEffect)
        StartParticleFxNonLoopedAtCoord(
            effect.particleName,
            coords.x,
            coords.y,
            coords.z,
            0.0,
            0.0,
            0.0,
            1.0,
            false,
            false,
            false
        )
    end
end

local function canTeleport()
    local now = GetGameTimer()
    local cooldown = Config.TeleportTransition.cooldownMs or 0

    if cooldown > 0 and now - lastTeleport < cooldown then
        local remaining = math.ceil((cooldown - (now - lastTeleport)) / 1000)

        QBCore.Functions.Notify(('Please wait %d second(s) before teleporting again.'):format(remaining), 'error')
        return false
    end

    return true
end

local function teleportPlayer(interiorId, coords, label)
    if not canTeleport() then
        return
    end

    lastTeleport = GetGameTimer()

    local transition = Config.TeleportTransition
    local audio = transition.audio or {}

    if transition.enabled then
        if audio.enabled then
            if audio.departureDelayMs > 0 then
                Wait(audio.departureDelayMs)
            end

            playSound(audio.departureSound, audio.departureSoundSet)
        end

        DoScreenFadeOut(transition.fadeOutMs)

        while not IsScreenFadedOut() do
            Wait(10)
        end
    end

    local playerPed = PlayerPedId()

    SetEntityCoords(playerPed, coords.x, coords.y, coords.z, false, false, false, false)
    currentInterior = interiorId

    playTeleportEffect(coords)

    if transition.enabled then
        if audio.enabled then
            if audio.arrivalDelayMs > 0 then
                Wait(math.max(0, audio.arrivalDelayMs - transition.fadeOutMs))
            end

            playSound(audio.arrivalSound, audio.arrivalSoundSet)
        end

        Wait(math.max(0, transition.particleDurationMs - transition.fadeOutMs))
        DoScreenFadeIn(transition.fadeInMs)
    end

    QBCore.Functions.Notify(('Teleported to %s.'):format(label), 'success')
end

RegisterNetEvent('whellco_immersive_interiors:teleport', function(data)
    if not data or not data.coords then
        return
    end

    local interiorId = data.interiorId

    if not requestInterior(interiorId) then
        QBCore.Functions.Notify('Interior could not be loaded.', 'error')
        return
    end

    teleportPlayer(interiorId, data.coords, data.label)
end)

RegisterNetEvent('whellco_immersive_interiors:notify', function(message, type)
    QBCore.Functions.Notify(message, type or 'primary')
end)

CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local Player = QBCore.Functions.GetPlayerData()

        for id, interior in pairs(Config.Interiors) do
            local entryDistance = #(coords - interior.entry)
            local exitDistance = #(coords - interior.exit)

            if entryDistance < Config.LoadDistance and not loadedInteriors[id] then
                requestInterior(id)
            elseif entryDistance > Config.UnloadDistance and loadedInteriors[id] then
                releaseInterior(id)
            end

            if entryDistance < Config.InteractionDistance and hasJobAccess(Player, interior) then
                sleep = 0

                QBCore.Functions.DrawText3D(interior.entry.x, interior.entry.y, interior.entry.z, ('[E] Enter %s'):format(interior.label))

                if IsControlJustReleased(0, 38) then
                    teleportPlayer(id, interior.exit, interior.label)
                end
            end

            if exitDistance < Config.InteractionDistance and currentInterior == id then
                sleep = 0

                QBCore.Functions.DrawText3D(interior.exit.x, interior.exit.y, interior.exit.z, ('[E] Exit %s'):format(interior.label))

                if IsControlJustReleased(0, 38) then
                    teleportPlayer(id, interior.entry, interior.label)
                end
            end

            for _, interaction in ipairs(Config.Interactions[id] or {}) do
                local distance = #(coords - interaction.coords)

                if distance < Config.InteractionDistance and hasInteractionAccess(Player, interaction) then
                    sleep = 0

                    QBCore.Functions.DrawText3D(interaction.coords.x, interaction.coords.y, interaction.coords.z, ('[E] %s'):format(interaction.label))

                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent('whellco_immersive_interiors:interact', id, interaction.id)
                    end
                end
            end
        end

        Wait(sleep)
    end
end)