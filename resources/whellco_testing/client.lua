local testingMenuOpen = false

local function openTestingMenu(data)
    if testingMenuOpen then
        return
    end

    testingMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        suites = data.suites,
        results = data.results
    })
end

local function closeTestingMenu()
    if not testingMenuOpen then
        return
    end

    testingMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_testing:openMenu', openTestingMenu)

RegisterNetEvent('whellco_testing:closeMenu', closeTestingMenu)

RegisterNetEvent('whellco_testing:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('testing', function()
    TriggerServerEvent('whellco_testing:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_testing:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('runSuite', function(data, cb)
    TriggerServerEvent('whellco_testing:runSuite', data.suite)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
