local releaseMenuOpen = false

local function openReleaseMenu(data)
    if releaseMenuOpen then
        return
    end

    releaseMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        version = data.version,
        releases = data.releases
    })
end

local function closeReleaseMenu()
    if not releaseMenuOpen then
        return
    end

    releaseMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_release:openMenu', openReleaseMenu)

RegisterNetEvent('whellco_release:closeMenu', closeReleaseMenu)

RegisterNetEvent('whellco_release:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('release', function()
    TriggerServerEvent('whellco_release:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_release:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('viewRelease', function(data, cb)
    TriggerServerEvent('whellco_release:viewRelease', data.version)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
