local chickens = {}
local footprints = {}

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
            lastSquawk = 0,
            lastFeather = 0,
            lastFootprint = 0
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

                if distance < chicken.config.panicDistance then
                    if not chicken.panicking then
                        panicChicken(chicken, playerCoords)
                    else
                        playPanicSound(chicken)
                        dropFeathers(chicken)
                        leaveFootprints(chicken)
                    end
                elseif chicken.panicking and distance > chicken.config.calmDistance then
                    chicken.panicking = false
                    wanderChicken(chicken)
                end
            end
        end

        updateFootprints()
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    clearChickens()
    clearFootprints()
end)