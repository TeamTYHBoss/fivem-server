local chickens = {}

local function clearChickens()
    for _, chicken in ipairs(chickens) do
        if DoesEntityExist(chicken.ped) then
            DeletePed(chicken.ped)
        end
    end

    chickens = {}
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
            config = config
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

CreateThread(function()
    while true do
        Wait(1000)

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
                wanderChicken(chicken)
            end
        end

        Wait(Config.Chickens[1] and Config.Chickens[1].wanderInterval or 8000)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    clearChickens()
end)