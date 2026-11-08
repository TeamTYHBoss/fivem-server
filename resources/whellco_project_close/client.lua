local projectCloseMenuOpen = false

local function openProjectCloseMenu(data)
    if projectCloseMenuOpen then
        return
    end

    projectCloseMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        steps = data.steps,
        records = data.records
    })
end

local function closeProjectCloseMenu()
    if not projectCloseMenuOpen then
        return
    end

    projectCloseMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_project_close:openMenu', openProjectCloseMenu)

RegisterNetEvent('whellco_project_close:closeMenu', closeProjectCloseMenu)

RegisterNetEvent('whellco_project_close:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('projectclose', function()
    TriggerServerEvent('whellco_project_close:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_project_close:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('completeStep', function(data, cb)
    TriggerServerEvent('whellco_project_close:completeStep', data.step)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
