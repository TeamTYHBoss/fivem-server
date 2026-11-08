local QBCore = exports['qb-core']:GetCoreObject()

local streetLightLevel = 0.0
local houseLights = {}
local entityPools = {}
local swimmingNpcs = {}
local lastSplash = {}
local wasInWater = false

RegisterNetEvent('whellco_weather:setWeather', function(weather)
    if not weather then
        return
    end

    SetWeatherTypeOvertimePersist(weather, 15.0)
end)

RegisterNetEvent('whellco_weather:setTime', function(hour, minute, second)
    if not hour or not minute or not second then
        return
    end

    SetClockTime(hour, minute, second)
end)

RegisterNetEvent('whellco_weather:setNight', function(isNight)
    if isNight then
        SetArtificialLightsState(true)
    else
        SetArtificialLightsState(false)
    end
end)

local function updateStreetLights()
    local hour = GetClockHours()
    local minute = GetClockMinutes()
    local time = hour + (minute / 60.0)

    local targetLevel = 0.0

    if time >= 18.0 and time < 19.0 then
        targetLevel = (time - 18.0)
    elseif time >= 19.0 or time < 6.0 then
        targetLevel = 1.0
    elseif time >= 6.0 and time < 7.0 then
        targetLevel = 1.0 - (time - 6.0)
    end

    streetLightLevel = streetLightLevel + ((targetLevel - streetLightLevel) * 0.05)

    if streetLightLevel > 0.0 then
        SetArtificialLightsState(true)
    else
        SetArtificialLightsState(false)
    end
end

local function getOrCreateEntity(pool, key, model, x, y, z, heading, isPed)
    local entity = pool[key]

    if entity and DoesEntityExist(entity) then
        return entity
    end

    local hash = GetHashKey(model)

    RequestModel(hash)

    while not HasModelLoaded(hash) do
        Wait(0)
    end

    if isPed then
        entity = CreatePed(4, hash, x, y, z, heading, false, true)
        SetEntityAsMissionEntity(entity, true, true)
        FreezeEntityPosition(entity, true)
        SetBlockingOfNonTemporaryEvents(entity, true)
    else
        entity = CreateObject(hash, x, y, z, false, false, false)
        SetEntityHeading(entity, heading)
        FreezeEntityPosition(entity, true)
    end

    pool[key] = entity

    return entity
end

local function updateHouseLights()
    local hour = GetClockHours()
    local minute = GetClockMinutes()
    local time = hour + (minute / 60.0)

    local isNight = time >= 18.0 or time < 6.0

    for _, house in ipairs(Config.Houses) do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - house.coords)

        if distance < house.lightDistance then
            if isNight then
                if not houseLights[house.id] then
                    houseLights[house.id] = {}

                    for index, window in ipairs(house.windows) do
                        UseParticleFxAssetNextCall('core')
                        local handle = StartParticleFxLoopedAtCoord(
                            'exp_grd_bzgas_smoke',
                            window.x,
                            window.y,
                            window.z,
                            0.0,
                            0.0,
                            0.0,
                            0.3,
                            false,
                            false,
                            false
                        )

                        houseLights[house.id][#houseLights[house.id] + 1] = {
                            handle = handle,
                            isTv = index <= house.tvWindowCount
                        }
                    end
                end

                for _, light in ipairs(houseLights[house.id]) do
                    if light.isTv and DoesParticleFxLoopedExist(light.handle) then
                        local flicker = math.random(50, 100) / 100
                        SetParticleFxLoopedScale(light.handle, 0.3 * flicker, 0.3 * flicker, 0.3 * flicker)
                        SetParticleFxLoopedColour(light.handle, house.tvColour.r, house.tvColour.g, house.tvColour.b, false)
                    end
                end
            else
                if houseLights[house.id] then
                    for _, light in ipairs(houseLights[house.id]) do
                        if DoesParticleFxLoopedExist(light.handle) then
                            StopParticleFxLooped(light.handle, false)
                        end
                    end

                    houseLights[house.id] = nil
                end
            end

            if house.curtains and #house.curtains > 0 then
                if not entityPools[house.id] then
                    entityPools[house.id] = {}
                end

                if not entityPools[house.id].curtains then
                    entityPools[house.id].curtains = {}
                end

                for index, curtain in ipairs(house.curtains) do
                    getOrCreateEntity(entityPools[house.id].curtains, index, curtain.model, curtain.x, curtain.y, curtain.z, curtain.heading or 0.0, false)
                end

                if house.silhouettes and #house.silhouettes > 0 then
                    if not entityPools[house.id].silhouettes then
                        entityPools[house.id].silhouettes = {}
                    end

                    for index, silhouette in ipairs(house.silhouettes) do
                        getOrCreateEntity(entityPools[house.id].silhouettes, index, silhouette.model, silhouette.x, silhouette.y, silhouette.z, silhouette.heading or 0.0, false)
                    end
                end
            end

            if house.npcs and #house.npcs > 0 then
                if not entityPools[house.id] then
                    entityPools[house.id] = {}
                end

                if not entityPools[house.id].npcs then
                    entityPools[house.id].npcs = {}
                end

                for index, npc in ipairs(house.npcs) do
                    getOrCreateEntity(entityPools[house.id].npcs, index, npc.model, npc.x, npc.y, npc.z, npc.heading or 0.0, true)
                end
            end

            if house.items and #house.items > 0 then
                if not entityPools[house.id] then
                    entityPools[house.id] = {}
                end

                if not entityPools[house.id].items then
                    entityPools[house.id].items = {}
                end

                for index, item in ipairs(house.items) do
                    getOrCreateEntity(entityPools[house.id].items, index, item.model, item.x, item.y, item.z, item.heading or 0.0, false)
                end
            end
        else
            if houseLights[house.id] then
                for _, light in ipairs(houseLights[house.id]) do
                    if DoesParticleFxLoopedExist(light.handle) then
                        StopParticleFxLooped(light.handle, false)
                    end
                end

                houseLights[house.id] = nil
            end

            if entityPools[house.id] then
                for _, pool in pairs(entityPools[house.id]) do
                    for _, entity in pairs(pool) do
                        if DoesEntityExist(entity) then
                            DeleteEntity(entity)
                        end
                    end
                end

                entityPools[house.id] = nil
            end
        end
    end
end

local function playSplash(coords, isDive)
    local now = GetGameTimer()
    local key = coords.x .. coords.y .. coords.z
    local cooldown = isDive and 250 or 500

    if lastSplash[key] and now - lastSplash[key] < cooldown then
        return
    end

    lastSplash[key] = now

    UseParticleFxAssetNextCall('core')
    StartParticleFxNonLoopedAtCoord(
        isDive and 'water_ripples' or 'water_splash',
        coords.x,
        coords.y,
        coords.z,
        0.0,
        0.0,
        0.0,
        isDive and 1.5 or 1.0,
        false,
        false,
        false
    )

    PlaySoundFromCoord(-1, isDive and 'SPLASH_BIG' or 'SPLASH', coords.x, coords.y, coords.z, 'HUD_FRONTEND_DEFAULT_SOUNDSET', false, 0, false)
end

local function updatePlayerWater()
    local playerPed = PlayerPedId()
    local inWater = IsPedInWater(playerPed)
    local playerCoords = GetEntityCoords(playerPed)

    if inWater and not wasInWater then
        playSplash(playerCoords, true)
    end

    wasInWater = inWater
end

local function updateSwimmingPools()
    local playerCoords = GetEntityCoords(PlayerPedId())

    for _, pool in ipairs(Config.SwimmingPools) do
        local distance = #(playerCoords - pool.coords)

        if distance < pool.activateDistance then
            if not swimmingNpcs[pool.id] then
                swimmingNpcs[pool.id] = {}

                for index = 1, pool.maxNpcs do
                    if math.random(1, 100) <= pool.npcChance then
                        local npc = pool.npcs[math.random(#pool.npcs)]
                        local model = GetHashKey(npc.model)

                        RequestModel(model)

                        while not HasModelLoaded(model) do
                            Wait(0)
                        end

                        local ped = CreatePed(4, model, npc.x, npc.y, npc.z, npc.heading or 0.0, false, true)

                        SetEntityAsMissionEntity(ped, true, true)
                        SetBlockingOfNonTemporaryEvents(ped, true)
                        SetPedDiesWhenInjured(ped, false)
                        SetPedCanRagdollFromPlayerImpact(ped, false)

                        if npc.swimming then
                            SetPedCoordsNoOffset(ped, npc.x, npc.y, npc.z, false, false, false)
                            SetPedConfigFlag(ped, 1, true)
                            TaskSwimToCoord(ped, npc.x + math.random(-5, 5), npc.y + math.random(-5, 5), npc.z)
                            playSplash(vector3(npc.x, npc.y, npc.z), false)
                        else
                            FreezeEntityPosition(ped, true)
                        end

                        swimmingNpcs[pool.id][#swimmingNpcs[pool.id] + 1] = ped
                    end
                end
            end

            for _, ped in ipairs(swimmingNpcs[pool.id]) do
                if DoesEntityExist(ped) then
                    local pedCoords = GetEntityCoords(ped)
                    local speed = GetEntitySpeed(ped)

                    if speed > 0.5 and IsEntityInWater(ped) then
                        playSplash(pedCoords, false)
                    end
                end
            end
        else
            if swimmingNpcs[pool.id] then
                for _, ped in ipairs(swimmingNpcs[pool.id]) do
                    if DoesEntityExist(ped) then
                        DeleteEntity(ped)
                    end
                end

                swimmingNpcs[pool.id] = nil
            end
        end
    end
end

local function startSwimmingAnimation(ped)
    if not DoesEntityExist(ped) then
        return
    end

    RequestAnimDict('swimming@swim')

    while not HasAnimDictLoaded('swimming@swim') do
        Wait(0)
    end

    TaskPlayAnim(ped, 'swimming@swim', 'idle', 8.0, -8.0, -1, 1, 0, false, false, false)
end

local function stopSwimmingAnimation(ped)
    if not DoesEntityExist(ped) then
        return
    end

    StopAnimTask(ped, 'swimming@swim', 'idle', 1.0)
    ClearPedTasks(ped)
end

CreateThread(function()
    while true do
        Wait(100)

        updateStreetLights()
        updateHouseLights()
        updateSwimmingPools()
        updatePlayerWater()
    end
end)