local medicalMenuOpen = false

local function openMedicalMenu(data)
    if medicalMenuOpen then
        return
    end

    medicalMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        jobs = data.jobs,
        injuries = data.injuries,
        treatments = data.treatments
    })
end

local function closeMedicalMenu()
    if not medicalMenuOpen then
        return
    end

    medicalMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_medical:openMenu', openMedicalMenu)

RegisterNetEvent('whellco_medical:closeMenu', closeMedicalMenu)

RegisterNetEvent('whellco_medical:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('medical', function()
    TriggerServerEvent('whellco_medical:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_medical:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('toggleDuty', function(data, cb)
    TriggerServerEvent('whellco_medical:toggleDuty', data.jobId)
    cb({ ok = true })
end)

RegisterNuiCallback('treatPatient', function(data, cb)
    TriggerServerEvent('whellco_medical:treatPatient', data.targetId, data.injuryType, data.treatment)
    cb({ ok = true })
end)

RegisterNuiCallback('healPatient', function(data, cb)
    TriggerServerEvent('whellco_medical:healPatient', data.targetId)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
