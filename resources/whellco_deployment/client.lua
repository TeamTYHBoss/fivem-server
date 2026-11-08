local deploymentMenuOpen = false

local function openDeploymentMenu(data)
    if deploymentMenuOpen then
        return
    end

    deploymentMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        checks = data.checks,
        history = data.history
    })
end

local function closeDeploymentMenu()
    if not deploymentMenuOpen then
        return
    end

    deploymentMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_deployment:openMenu', openDeploymentMenu)

RegisterNetEvent('whellco_deployment:closeMenu', closeDeploymentMenu)

RegisterNetEvent('whellco_deployment:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('deployment', function()
    TriggerServerEvent('whellco_deployment:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_deployment:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('runChecks', function(_, cb)
    TriggerServerEvent('whellco_deployment:runChecks')
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
