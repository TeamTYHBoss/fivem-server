local dealershipMenuOpen = false
local garageMenuOpen = false
local currentVehicle = 0

local function openDealershipMenu(data)
    if dealershipMenuOpen then
        return
    end

    dealershipMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openDealership',
        vehicles = data.vehicles
    })
end

local function closeDealershipMenu()
    if not dealershipMenuOpen then
        return
    end

    dealershipMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

local function openGarageMenu(data)
    if garageMenuOpen then
        return
    end

    garageMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openGarage',
        vehicles = data.vehicles,
        customization = data.customization
    })
end

local function closeGarageMenu()
    if not garageMenuOpen then
        return
    end

    garageMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_dealership:openDealership', openDealershipMenu)
RegisterNetEvent('whellco_dealership:closeMenu', function()
    closeDealershipMenu()
    closeGarageMenu()
end)

RegisterNetEvent('whellco_dealership:openGarage', openGarageMenu)

RegisterNetEvent('whellco_dealership:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterNetEvent('whellco_dealership:spawnVehicle', function(data)
    local model = data.model

    if not IsModelInCdimage(model) then
        return
    end

    RequestModel(model)

    local timeout = GetGameTimer() + 10000

    while not HasModelLoaded(model) and GetGameTimer() < timeout do
        Wait(0)
    end

    if not HasModelLoaded(model) then
        return
    end

    if currentVehicle ~= 0 then
        DeleteVehicle(currentVehicle)
    end

    local coords = data.coords
    local heading = data.heading

    currentVehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
    SetVehicleNumberPlateText(currentVehicle, data.plate)
    SetVehicleColours(currentVehicle, data.primaryColor, data.secondaryColor)
    SetVehicleExtraColours(currentVehicle, data.pearlColor, data.wheelColor)
    SetVehicleModKit(currentVehicle, 0)

    if data.engineLevel then
        SetVehicleMod(currentVehicle, 11, data.engineLevel, false)
    end

    if data.brakesLevel then
        SetVehicleMod(currentVehicle, 12, data.brakesLevel, false)
    end

    if data.transmissionLevel then
        SetVehicleMod(currentVehicle, 13, data.transmissionLevel, false)
    end

    if data.armorLevel then
        SetVehicleMod(currentVehicle, 16, data.armorLevel, false)
    end

    ToggleVehicleMod(currentVehicle, 18, data.turbo or false)

    SetVehicleEngineOn(currentVehicle, true, true, false)
    SetPedIntoVehicle(PlayerPedId(), currentVehicle, -1)

    SetModelAsNoLongerNeeded(model)
end)

RegisterCommand('dealership', function()
    TriggerServerEvent('whellco_dealership:openDealership')
end, false)

RegisterCommand('garage', function()
    TriggerServerEvent('whellco_dealership:openGarage')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_dealership:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('buyVehicle', function(data, cb)
    TriggerServerEvent('whellco_dealership:buyVehicle', data.vehicleId)
    cb({ ok = true })
end)

RegisterNuiCallback('retrieveVehicle', function(data, cb)
    TriggerServerEvent('whellco_dealership:retrieveVehicle', data.vehicleId)
    cb({ ok = true })
end)

RegisterNuiCallback('storeVehicle', function(data, cb)
    TriggerServerEvent('whellco_dealership:storeVehicle', data.vehicleId)
    cb({ ok = true })
end)

RegisterNuiCallback('customizeVehicle', function(data, cb)
    TriggerServerEvent('whellco_dealership:customizeVehicle', data.vehicleId, data.customizationType, data.value)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)

        if currentVehicle ~= 0 then
            DeleteVehicle(currentVehicle)
        end
    end
end)
