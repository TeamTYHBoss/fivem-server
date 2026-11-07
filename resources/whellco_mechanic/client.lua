local mechanicMenuOpen = false

local function openMechanicMenu(data)
    if mechanicMenuOpen then
        return
    end

    mechanicMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        jobs = data.jobs,
        repairs = data.repairs,
        upgrades = data.upgrades
    })
end

local function closeMechanicMenu()
    if not mechanicMenuOpen then
        return
    end

    mechanicMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_mechanic:openMenu', openMechanicMenu)

RegisterNetEvent('whellco_mechanic:closeMenu', closeMechanicMenu)

RegisterNetEvent('whellco_mechanic:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('mechanic', function()
    TriggerServerEvent('whellco_mechanic:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_mechanic:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('toggleDuty', function(data, cb)
    TriggerServerEvent('whellco_mechanic:toggleDuty', data.jobId)
    cb({ ok = true })
end)

RegisterNuiCallback('repairVehicle', function(data, cb)
    TriggerServerEvent('whellco_mechanic:repairVehicle', data.plate, data.repairType)
    cb({ ok = true })
end)

RegisterNuiCallback('upgradeVehicle', function(data, cb)
    TriggerServerEvent('whellco_mechanic:upgradeVehicle', data.plate, data.upgradeType)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
