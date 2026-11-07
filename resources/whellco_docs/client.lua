local docsMenuOpen = false

local function openDocsMenu(data)
    if docsMenuOpen then
        return
    end

    docsMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        sections = data.sections
    })
end

local function closeDocsMenu()
    if not docsMenuOpen then
        return
    end

    docsMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_docs:openMenu', openDocsMenu)

RegisterNetEvent('whellco_docs:closeMenu', closeDocsMenu)

RegisterNetEvent('whellco_docs:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('docs', function()
    TriggerServerEvent('whellco_docs:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_docs:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('viewSection', function(data, cb)
    TriggerServerEvent('whellco_docs:viewSection', data.section)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
