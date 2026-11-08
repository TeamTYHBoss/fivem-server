local completionMenuOpen = false

local function openCompletionMenu(data)
    if completionMenuOpen then
        return
    end

    completionMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        steps = data.steps,
        records = data.records
    })
end

local function closeCompletionMenu()
    if not completionMenuOpen then
        return
    end

    completionMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_completion:openMenu', openCompletionMenu)

RegisterNetEvent('whellco_completion:closeMenu', closeCompletionMenu)

RegisterNetEvent('whellco_completion:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('completion', function()
    TriggerServerEvent('whellco_completion:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_completion:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('completeStep', function(data, cb)
    TriggerServerEvent('whellco_completion:completeStep', data.step)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
