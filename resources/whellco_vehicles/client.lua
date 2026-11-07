local garageOpen = false
local dealershipOpen = false
local ownedVehicle = nil

local function openGarage(data)
    if garageOpen then
        return
    end

    garageOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openGarage',
        vehicles = data.vehicles
    })
end

local function closeGarage()
    if not garageOpen then
        return
    end

    garageOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'closeGarage'
    })
end

local function openDealership(data)
    if dealershipOpen then
        return
    end

    dealershipOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openDealership',
        vehicles = data.vehicles,
        cash = data.cash
    })
end

local function closeDealership()
    if not dealershipOpen then
        return
    end

    dealershipOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'closeDealership'
    })
end

RegisterNetEvent('whellco_vehicles:openGarage', openGarage)

RegisterNetEvent('whellco_vehicles:openDealership', openDealership)

RegisterNetEvent('whellco_vehicles:closeGarage', closeGarage)

RegisterNetEvent('whellco_vehicles:closeDealership', closeDealership)

RegisterNetEvent('whellco_vehicles:vehicleSpawned', function(data)
    ownedVehicle = data.vehicle
end)

RegisterNetEvent('whellco_vehicles:vehicleStored', function()
    ownedVehicle = nil
end)

RegisterNetEvent('whellco_vehicles:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('garage', function()
    TriggerServerEvent('whellco_vehicles:openGarage', 'legion_garage')
end, false)

RegisterCommand('dealership', function()
    TriggerServerEvent('whellco_vehicles:openDealership')
end, false)

RegisterNuiCallback('closeGarage', function(_, cb)
    TriggerServerEvent('whellco_vehicles:closeGarage')
    cb({ ok = true })
end)

RegisterNuiCallback('spawnVehicle', function(data, cb)
    TriggerServerEvent('whellco_vehicles:spawnVehicle', data.vehicleId)
    cb({ ok = true })
end)

RegisterNuiCallback('storeVehicle', function(_, cb)
    TriggerServerEvent('whellco_vehicles:storeVehicle')
    cb({ ok = true })
end)

RegisterNuiCallback('closeDealership', function(_, cb)
    TriggerServerEvent('whellco_vehicles:closeDealership')
    cb({ ok = true })
end)

RegisterNuiCallback('purchaseVehicle', function(data, cb)
    TriggerServerEvent('whellco_vehicles:purchaseVehicle', data.model)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
