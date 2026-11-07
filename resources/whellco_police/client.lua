local policeMenuOpen = false

local function openPoliceMenu(data)
    if policeMenuOpen then
        return
    end

    policeMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        jobs = data.jobs,
        citations = data.citations,
        arrests = data.arrests
    })
end

local function closePoliceMenu()
    if not policeMenuOpen then
        return
    end

    policeMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_police:openMenu', openPoliceMenu)

RegisterNetEvent('whellco_police:closeMenu', closePoliceMenu)

RegisterNetEvent('whellco_police:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('police', function()
    TriggerServerEvent('whellco_police:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_police:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('toggleDuty', function(data, cb)
    TriggerServerEvent('whellco_police:toggleDuty', data.jobId)
    cb({ ok = true })
end)

RegisterNuiCallback('issueCitation', function(data, cb)
    TriggerServerEvent('whellco_police:issueCitation', data.targetId, data.citationType)
    cb({ ok = true })
end)

RegisterNuiCallback('arrestPlayer', function(data, cb)
    TriggerServerEvent('whellco_police:arrestPlayer', data.targetId, data.reason)
    cb({ ok = true })
end)

RegisterNuiCallback('releasePlayer', function(data, cb)
    TriggerServerEvent('whellco_police:releasePlayer', data.targetId)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
