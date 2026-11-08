local QBCore = exports['qb-core']:GetCoreObject()

local streetLightLevel = 0.0
local houseLights = {}
local houseCurtains = {}

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
                if not houseCurtains[house.id] then
                    houseCurtains[house.id] = {}

                    for _, curtain in ipairs(house.curtains) do
                        local model = GetHashKey(curtain.model)

                        RequestModel(model)

                        while not HasModelLoaded(model) do
                            Wait(0)
                        end

                        local object = CreateObject(model, curtain.x, curtain.y, curtain.z, false, false, false)

                        SetEntityHeading(object, curtain.heading or 0.0)
                        FreezeEntityPosition(object, true)

                        houseCurtains[house.id][#houseCurtains[house.id] + 1] = object
                    end
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

            if houseCurtains[house.id] then
                for _, object in ipairs(houseCurtains[house.id]) do
                    if DoesEntityExist(object) then
                        DeleteEntity(object)
                    end
                end

                houseCurtains[house.id] = nil
            end
        end
    end
end

CreateThread(function()
    while true do
        Wait(100)

        updateStreetLights()
        updateHouseLights()
    end
end)