local economyMenuOpen = false

local function openEconomyMenu(data)
    if economyMenuOpen then
        return
    end

    economyMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        balance = data.balance,
        sections = data.sections,
        receipts = data.receipts
    })
end

local function closeEconomyMenu()
    if not economyMenuOpen then
        return
    end

    economyMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_economy_hub:openMenu', openEconomyMenu)

RegisterNetEvent('whellco_economy_hub:closeMenu', closeEconomyMenu)

RegisterNetEvent('whellco_economy_hub:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('economy', function()
    TriggerServerEvent('whellco_economy_hub:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_economy_hub:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('openSection', function(data, cb)
    TriggerServerEvent('whellco_economy_hub:openSection', data.section)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
