local polishMenuOpen = false

local function openPolishMenu(data)
    if polishMenuOpen then
        return
    end

    polishMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        checks = data.checks,
        reviews = data.reviews
    })
end

local function closePolishMenu()
    if not polishMenuOpen then
        return
    end

    polishMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_polish:openMenu', openPolishMenu)

RegisterNetEvent('whellco_polish:closeMenu', closePolishMenu)

RegisterNetEvent('whellco_polish:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('polish', function()
    TriggerServerEvent('whellco_polish:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_polish:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('runReview', function(_, cb)
    TriggerServerEvent('whellco_polish:runReview')
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
