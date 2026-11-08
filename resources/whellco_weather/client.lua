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

CreateThread(function()
    while true do
        Wait(1000)

        local hour = GetClockHours()
        local minute = GetClockMinutes()

        if hour >= 6 and hour < 8 then
            SetArtificialLightsState(false)
        elseif hour >= 18 or hour < 6 then
            SetArtificialLightsState(true)
        end
    end
end)