local audioMenuOpen = false

local function openAudioMenu(data)
    if audioMenuOpen then
        return
    end

    audioMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        vehicles = data.vehicles,
        audio = data.audio,
        systems = data.systems,
        volumes = data.volumes
    })
end

local function closeAudioMenu()
    if not audioMenuOpen then
        return
    end

    audioMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_audio:openMenu', openAudioMenu)

RegisterNetEvent('whellco_audio:closeMenu', closeAudioMenu)

RegisterNetEvent('whellco_audio:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('audio', function()
    TriggerServerEvent('whellco_audio:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_audio:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('applyAudio', function(data, cb)
    TriggerServerEvent('whellco_audio:applyAudio', data.vehicleId, data.systemId, data.volumeId)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
