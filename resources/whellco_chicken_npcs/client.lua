local chickens = {}
local footprints = {}
local flourEffects = {}
local wetFootprints = {}

local function clearChickens()
    for _, chicken in ipairs(chickens) do
        if DoesEntityExist(chicken.ped) then
            DeletePed(chicken.ped)
        end
    end

    chickens = {}
end

local function clearFootprints()
    for _, footprint in ipairs(footprints) do
        if DoesParticleFxLoopedExist(footprint.handle) then
            StopParticleFxLooped(footprint.handle, false)
        end
    end

    footprints = {}
end

local function clearFlourEffects()
    for _, effect in ipairs(flourEffects) do
        if DoesParticleFxLoopedExist(effect.handle) then
            StopParticleFxLooped(effect.handle, false)
        end
    end

    flourEffects = {}
end

local function clearWetFootprints()
    for _, footprint in ipairs(wetFootprints) do
        if DoesParticleFxLoopedExist(footprint.handle) then
            StopParticleFxLooped(footprint.handle, false)
        end
    end

    wetFootprints = {}
end

local function spawnChicken(config)
    local ped = CreatePed(28, GetHashKey(config.model), config.coords.x, config.coords.y, config.coords.z, config.heading, false, true)

    if ped and ped ~= 0 then
        SetEntityAsMissionEntity(ped, true, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedFleeAttributes(ped, 0, false)
        SetPedCanRagdollFromPlayerImpact(ped, false)
        SetEntityInvincible(ped, true)

        chickens[#chickens + 1] = {
            ped = ped,
            config = config,
            panicking = false,
            wet = false,
            lastSquawk = 0,
            lastFeather = 0,
            lastFootprint = 0,
            lastFlour = 0,
            lastWetFootprint = 0,
            lastShake = 0
        }
    end
end

local function wanderChicken(chicken)
    local config = chicken.config
    local angle = math.rad(math.random(0, 360))
    local distance = math.random(1, config.wanderRadius)
    local targetX = config.coords.x + (math.cos(angle) * distance)
    local targetY = config.coords.y + (math.sin(angle) * distance)
    local targetZ = config.coords.z

    TaskGoToCoordAnyMeans(chicken.ped, targetX, targetY, targetZ, 1.0, 0, 0, 786603, 0.0)
end

local function playPanicSound(chicken)
    local currentTime = GetGameTimer()

    if currentTime - chicken.lastSquawk < chicken.config.squawkInterval then
        return
    end

    chicken.lastSquawk = currentTime

    local chickenCoords = GetEntityCoords(chicken.ped)

    PlaySoundFromCoord(
        -1,
        'SELECT',
        chickenCoords.x,
        chickenCoords.y,
        chickenCoords.z,
        'HUD_FRONTEND_DEFAULT_SOUNDSET',
        false,
        80,
        false
    )
end

local function dropFeathers(chicken)
    local currentTime = GetGameTimer()

    if currentTime - chicken.lastFeather < chicken.config.featherInterval then
        return
    end

    chicken.lastFeather = currentTime

    local chickenCoords = GetEntityCoords(chicken.ped)
    local offsetX = math.random(-50, 50) / 100
    local offsetY = math.random(-50, 50) / 100

    UseParticleFxAssetNextCall('core')
    StartParticleFxNonLoopedAtCoord(
        'exp_grd_bzgas_smoke',
        chickenCoords.x + offsetX,
        chickenCoords.y + offsetY,
        chickenCoords.z,
        0.0,
        0.0,
        0.0,
        0.4,
        false,
        false,
        false
    )
end

local function leaveFootprints(chicken)
    local currentTime = GetGameTimer()

    if currentTime - chicken.lastFootprint < chicken.config.footprintInterval then
        return
    end

    chicken.lastFootprint = currentTime

    local chickenCoords = GetEntityCoords(chicken.ped)
    local heading = GetEntityHeading(chicken.ped)
    local offsetX = math.random(-20, 20) / 100
    local offsetY = math.random(-20, 20) / 100

    UseParticleFxAssetNextCall('core')
    local handle = StartParticleFxLoopedAtCoord(
        'exp_grd_bzgas_smoke',
        chickenCoords.x + offsetX,
        chickenCoords.y + offsetY,
        chickenCoords.z - 0.95,
        0.0,
        0.0,
        heading,
        0.15,
        false,
        false,
        false
    )

    footprints[#footprints + 1] = {
        handle = handle,
        created = currentTime
    }
end

local function kickUpFlour(chicken)
    local currentTime = GetGameTimer()

    if currentTime - chicken.lastFlour < chicken.config.flourInterval then
        return
    end

    chicken.lastFlour = currentTime

    local chickenCoords = GetEntityCoords(chicken.ped)

    UseParticleFxAssetNextCall('core')
    local handle = StartParticleFxLoopedAtCoord(
        'exp_grd_bzgas_smoke',
        chickenCoords.x,
        chickenCoords.y,
        chickenCoords.z - 0.9,
        0.0,
        0.0,
        0.0,
        0.8,
        false,
        false,
        false
    )

    flourEffects[#flourEffects + 1] = {
        handle = handle,
        created = currentTime
    }
end

local function leaveWetFootprints(chicken)
    local currentTime = GetGameTimer()

    if currentTime - chicken.lastWetFootprint < chicken.config.wetFootprintInterval then
        return
    end

    chicken.lastWetFootprint = currentTime

    local chickenCoords = GetEntityCoords(chicken.ped)
    local heading = GetEntityHeading(chicken.ped)
    local offsetX = math.random(-20, 20) / 100
    local offsetY = math.random(-20, 20) / 100

    UseParticleFxAssetNextCall('core')
    local handle = StartParticleFxLoopedAtCoord(
        'exp_grd_bzgas_smoke',
        chickenCoords.x + offsetX,
        chickenCoords.y + offsetY,
        chickenCoords.z - 0.95,
        0.0,
        0.0,
        heading,
        0.2,
        false,
        false,
        false
    )

    wetFootprints[#wetFootprints + 1] = {
        handle = handle,
        created = currentTime
    }
end

local function shakeDry(chicken)
    local currentTime = GetGameTimer()

    if currentTime - chicken.lastShake < chicken.config.shakeInterval then
        return
    end

    chicken.lastShake = currentTime

    local chickenCoords = GetEntityCoords(chicken.ped)

    UseParticleFxAssetNextCall('core')
    StartParticleFxNonLoopedAtCoord(
        'exp_grd_bzgas_smoke',
        chickenCoords.x,
        chickenCoords.y,
        chickenCoords.z,
        0.0,
        0.0,
        0.0,
        0.6,
        false,
        false,
        false
    )

    for _ = 1, 6 do
        local offsetX = math.random(-80, 80) / 100
        local offsetY = math.random(-80, 80) / 100
        local offsetZ = math.random(20, 80) / 100

        UseParticleFxAssetNextCall('core')
        StartParticleFxNonLoopedAtCoord(
            'exp_grd_bzgas_smoke',
            chickenCoords.x + offsetX,
            chickenCoords.y + offsetY,
            chickenCoords.z + offsetZ,
            0.0,
            0.0,
            0.0,
            0.25,
            false,
            false,
            false
        )
    end

    chicken.wet = false
end

local function updateFootprints()
    local currentTime = GetGameTimer()

    for index = #footprints, 1, -1 do
        local footprint = footprints[index]
        local age = currentTime - footprint.created

        if age >= Config.FootprintLifetime then
            if DoesParticleFxLoopedExist(footprint.handle) then
                StopParticleFxLooped(footprint.handle, false)
            end

            table.remove(footprints, index)
        elseif age > Config.FootprintLifetime - Config.FootprintFadeTime then
            local fadeProgress = (age - (Config.FootprintLifetime - Config.FootprintFadeTime)) / Config.FootprintFadeTime
            local scale = 0.15 * (1.0 - fadeProgress)

            if DoesParticleFxLoopedExist(footprint.handle) then
                SetParticleFxLoopedScale(footprint.handle, scale, scale, scale)
            end
        end
    end
end

local function updateFlourEffects()
    local currentTime = GetGameTimer()

    for index = #flourEffects, 1, -1 do
        local effect = flourEffects[index]
        local age = currentTime - effect.created

        if age >= Config.FlourLifetime then
            if DoesParticleFxLoopedExist(effect.handle) then
                StopParticleFxLooped(effect.handle, false)
            end

            table.remove(flourEffects, index)
        elseif age > Config.FlourLifetime - Config.FlourFadeTime then
            local fadeProgress = (age - (Config.FlourLifetime - Config.FlourFadeTime)) / Config.FlourFadeTime
            local scale = 0.8 * (1.0 - fadeProgress)

            if DoesParticleFxLoopedExist(effect.handle) then
                SetParticleFxLoopedScale(effect.handle, scale, scale, scale)
            end
        end
    end
end

local function updateWetFootprints()
    local currentTime = GetGameTimer()

    for index = #wetFootprints, 1, -1 do
        local footprint = wetFootprints[index]
        local age = currentTime - footprint.created

        if age >= Config.WetFootprintLifetime then
            if DoesParticleFxLoopedExist(footprint.handle) then
                StopParticleFxLooped(footprint.handle, false)
            end

            table.remove(wetFootprints, index)
        elseif age > Config.WetFootprintLifetime - Config.WetFootprintFadeTime then
            local fadeProgress = (age - (Config.WetFootprintLifetime - Config.WetFootprintFadeTime)) / Config.WetFootprintFadeTime
            local scale = 0.2 * (1.0 - fadeProgress)

            if DoesParticleFxLoopedExist(footprint.handle) then
                SetParticleFxLoopedScale(footprint.handle, scale, scale, scale)
            end
        end
    end
end

local function panicChicken(chicken, playerCoords)
    local config = chicken.config
    local chickenCoords = GetEntityCoords(chicken.ped)
    local direction = chickenCoords - playerCoords
    local length = #direction

    if length == 0 then
        direction = vector3(1.0, 0.0, 0.0)
    else
        direction = direction / length
    end

    local runX = config.coords.x + (direction.x * config.panicDistance)
    local runY = config.coords.y + (direction.y * config.panicDistance)
    local runZ = config.coords.z

    ClearPedTasks(chicken.ped)
    TaskGoToCoordAnyMeans(chicken.ped, runX, runY, runZ, config.panicSpeed, 0, 0, 786603, 0.0)

    chicken.panicking = true
    playPanicSound(chicken)
    dropFeathers(chicken)
    leaveFootprints(chicken)

    if chicken.onCounter then
        kickUpFlour(chicken)
    end

    if chicken.nearSink then
        chicken.wet = true
        leaveWetFootprints(chicken)
    end
end

CreateThread(function()
    while true do
        Wait(500)

        local playerCoords = GetEntityCoords(PlayerPedId())

        for _, config in ipairs(Config.Chickens) do
            local distance = #(playerCoords - config.coords)
            local spawned = false

            for _, chicken in ipairs(chickens) do
                if chicken.config.id == config.id then
                    spawned = true
                end
            end

            if distance < Config.SpawnDistance and not spawned then
                spawnChicken(config)
            elseif distance > Config.DespawnDistance and spawned then
                for index, chicken in ipairs(chickens) do
                    if chicken.config.id == config.id then
                        if DoesEntityExist(chicken.ped) then
                            DeletePed(chicken.ped)
                        end

                        table.remove(chickens, index)
                    end
                end
            end
        end

        for _, chicken in ipairs(chickens) do
            if DoesEntityExist(chicken.ped) then
                local chickenCoords = GetEntityCoords(chicken.ped)
                local distance = #(playerCoords - chickenCoords)

                local onCounter = false
                local nearSink = false

                for _, counter in ipairs(chicken.config.counters) do
                    local counterDistance = #(chickenCoords - counter)

                    if counterDistance < 1.0 then
                        onCounter = true
                    end
                end

                for _, sink in ipairs(chicken.config.sinks) do
                    local sinkDistance = #(chickenCoords - sink)

                    if sinkDistance < 2.0 then
                        nearSink = true
                    end
                end

                chicken.onCounter = onCounter
                chicken.nearSink = nearSink

                if distance < chicken.config.panicDistance then
                    if not chicken.panicking then
                        panicChicken(chicken, playerCoords)
                    else
                        playPanicSound(chicken)
                        dropFeathers(chicken)
                        leaveFootprints(chicken)

                        if onCounter then
                            kickUpFlour(chicken)
                        end

                        if nearSink then
                            chicken.wet = true
                            leaveWetFootprints(chicken)
                        end
                    end
                elseif chicken.panicking and distance > chicken.config.calmDistance then
                    chicken.panicking = false

                    if chicken.wet then
                        shakeDry(chicken)
                    end

                    wanderChicken(chicken)
                end
            end
        end

        updateFootprints()
        updateFlourEffects()
        updateWetFootprints()
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    clearChickens()
    clearFootprints()
    clearFlourEffects()
    clearWetFootprints()
end)