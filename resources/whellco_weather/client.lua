local QBCore = exports['qb-core']:GetCoreObject()

local streetLightLevel = 0.0

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

CreateThread(function()
    while true do
        Wait(1000)

        updateStreetLights()
    end
end)