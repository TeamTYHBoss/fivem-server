local handoverMenuOpen = false

local function openHandoverMenu(data)
    if handoverMenuOpen then
        return
    end

    handoverMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        sections = data.sections,
        signoffs = data.signoffs
    })
end

local function closeHandoverMenu()
    if not handoverMenuOpen then
        return
    end

    handoverMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_handover:openMenu', openHandoverMenu)

RegisterNetEvent('whellco_handover:closeMenu', closeHandoverMenu)

RegisterNetEvent('whellco_handover:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('handover', function()
    TriggerServerEvent('whellco_handover:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_handover:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('signOffSection', function(data, cb)
    TriggerServerEvent('whellco_handover:signOffSection', data.section)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
