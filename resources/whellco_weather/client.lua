local QBCore = exports['qb-core']:GetCoreObject()

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
        SetNightvision(false)
        SetTimecycleModifier('hud_def_blur')
        SetTimecycleModifierStrength(0.0)
        SetArtificialLightsState(true)
    else
        SetArtificialLightsState(false)
    end
end)

CreateThread(function()
    while true do
        Wait(1000)

        local hour = GetClockHours()

        if hour >= 19 or hour < 6 then
            SetArtificialLightsState(true)
        else
            SetArtificialLightsState(false)
        end
    end
end)