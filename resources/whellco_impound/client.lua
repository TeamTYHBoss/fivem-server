local impoundMenuOpen = false

local function openImpoundMenu(data)
    if impoundMenuOpen then
        return
    end

    impoundMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        impounds = data.impounds
    })
end

local function closeImpoundMenu()
    if not impoundMenuOpen then
        return
    end

    impoundMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_impound:openMenu', openImpoundMenu)

RegisterNetEvent('whellco_impound:closeMenu', closeImpoundMenu)

RegisterNetEvent('whellco_impound:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('impound', function()
    TriggerServerEvent('whellco_impound:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_impound:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('releaseVehicle', function(data, cb)
    TriggerServerEvent('whellco_impound:releaseVehicle', data.impoundId)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
