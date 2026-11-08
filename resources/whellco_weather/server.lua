local QBCore = exports['qb-core']:GetCoreObject()

local currentWeather = 'CLEAR'

local function notify(source, message, kind)
    TriggerClientEvent('QBCore:Notify', source, message, kind or 'primary', 5000)
end

local function getSeasonalWeather(month)
    for _, season in ipairs(Config.SeasonalWeather or {}) do
        if season.month == month then
            return season.types or {}
        end
    end

    return Config.RealisticWeather or {}
end

local function selectWeather(month)
    local weatherTypes = getSeasonalWeather(month)
    local totalWeight = 0

    for _, weather in ipairs(weatherTypes) do
        totalWeight += weather.weight or 0
    end

    if totalWeight <= 0 then
        return 'CLEAR'
    end

    local roll = math.random() * totalWeight
    local runningWeight = 0

    for _, weather in ipairs(weatherTypes) do
        runningWeight += weather.weight or 0

        if roll <= runningWeight then
            return weather.type or 'CLEAR'
        end
    end

    return 'CLEAR'
end

local function updateWeather()
    local month = tonumber(os.date('%m')) or 1

    currentWeather = selectWeather(month)
    TriggerClientEvent('whellco_weather:setWeather', -1, currentWeather)
end

local function syncTime()
    local date = os.date('*t')

    TriggerClientEvent('whellco_weather:setTime', -1, date.hour, date.min, date.sec)

    local isNight = date.hour >= 19 or date.hour < 6
    TriggerClientEvent('whellco_weather:setNight', -1, isNight)
end

CreateThread(function()
    local weatherTimer = 0
    local weatherChangeInterval = Config.WeatherChangeInterval or 300

    while true do
        updateWeather()
        syncTime()

        Wait(1000)
        weatherTimer += 1

        if weatherTimer >= weatherChangeInterval then
            weatherTimer = 0
        end
    end
end)

RegisterCommand('weatherinfo', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    notify(source, ('Current weather: %s'):format(currentWeather), 'primary')
end, false)