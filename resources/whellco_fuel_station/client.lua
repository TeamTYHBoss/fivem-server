local QBCore = exports['qb-core']:GetCoreObject()

local currentFuel = 0.0

RegisterNetEvent('whellco_fuel_station:setFuel', function(fuel)
    currentFuel = fuel or 0.0

    QBCore.Functions.Notify(('Fuel level: %.1f%%'):format(currentFuel), 'primary')
end)

RegisterCommand('fuelinfo', function()
    local stations = {}

    for id, station in pairs(Config.GasStations) do
        stations[#stations + 1] = ('%s - %s'):format(id, station.label)
    end

    QBCore.Functions.Notify(table.concat(stations, ', '), 'primary')
end, false)