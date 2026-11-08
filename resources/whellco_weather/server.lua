local QBCore = exports['qb-core']:GetCoreObject()

local currentWeather = 'CLEAR'

local function getSeasonalWeather(month)
    for _, season in ipairs(Config.SeasonalWeather) do
        if season.month == month then
            return season.types
        end
    end

    return Config.RealisticWeather
end

local function selectWeather(month)
    local types = getSeasonalWeather(month)
    local totalWeight = 0

    for _, weather in ipairs(types) do
        totalWeight = totalWeight + weather.weight
    end

    local roll = math.random() * totalWeight
    local running = 0

    for _, weather in ipairs(types) do
        running = running + weather.weight

        if roll <= running then
            return weather.type
        end
    end

    return 'CLEAR'
end

local function updateWeather()
    local month = tonumber(os.date('%m'))

    currentWeather = selectWeather(month)

    TriggerClientEvent('whellco_weather:setWeather', -1, currentWeather)
end

local function syncTime()
    local time = os.time()
    local date = os.date('*t', time)

    TriggerClientEvent('whellco_weather:setTime', -1, date.hour, date.minute, date.second)
end

CreateThread(function()
    while true do
        updateWeather()
        syncTime()
        Wait(Config.SyncInterval)
    end
end)

CreateThread(function()
    while true do
        Wait(Config.WeatherChangeInterval)
        updateWeather()
    end
end)

RegisterCommand('weatherinfo', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    TriggerClientEvent('QBCore:Notify', source, ('Current weather: %s'):format(currentWeather), 'primary')
end, false)