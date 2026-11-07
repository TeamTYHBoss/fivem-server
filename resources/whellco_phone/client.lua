local phoneOpen = false

local function openPhone(data)
    if phoneOpen then
        return
    end

    phoneOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        contacts = data.contacts,
        messages = data.messages,
        calls = data.calls
    })
end

local function closePhone()
    if not phoneOpen then
        return
    end

    phoneOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_phone:openPhone', openPhone)

RegisterNetEvent('whellco_phone:closePhone', closePhone)

RegisterNetEvent('whellco_phone:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('phone', function()
    TriggerServerEvent('whellco_phone:openPhone')
end, false)

RegisterNuiCallback('closePhone', function(_, cb)
    TriggerServerEvent('whellco_phone:closePhone')
    cb({ ok = true })
end)

RegisterNuiCallback('addContact', function(data, cb)
    TriggerServerEvent('whellco_phone:addContact', data)
    cb({ ok = true })
end)

RegisterNuiCallback('sendMessage', function(data, cb)
    TriggerServerEvent('whellco_phone:sendMessage', data)
    cb({ ok = true })
end)

RegisterNuiCallback('startCall', function(data, cb)
    TriggerServerEvent('whellco_phone:startCall', data)
    cb({ ok = true })
end)

RegisterNuiCallback('endCall', function(data, cb)
    TriggerServerEvent('whellco_phone:endCall', data)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
