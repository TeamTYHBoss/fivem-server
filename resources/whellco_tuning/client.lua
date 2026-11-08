local tuningMenuOpen = false

local function openTuningMenu(data)
    if tuningMenuOpen then
        return
    end

    tuningMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        vehicles = data.vehicles,
        upgrades = data.upgrades
    })
end

local function closeTuningMenu()
    if not tuningMenuOpen then
        return
    end

    tuningMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_tuning:openMenu', openTuningMenu)

RegisterNetEvent('whellco_tuning:closeMenu', closeTuningMenu)

RegisterNetEvent('whellco_tuning:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('tuning', function()
    TriggerServerEvent('whellco_tuning:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_tuning:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('installUpgrade', function(data, cb)
    TriggerServerEvent('whellco_tuning:installUpgrade', data.vehicleId, data.part)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
