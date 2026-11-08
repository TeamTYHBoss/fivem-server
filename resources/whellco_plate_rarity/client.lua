local rarityMenuOpen = false

local function openRarityMenu(data)
    if rarityMenuOpen then
        return
    end

    rarityMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        plates = data.plates,
        rarityLevels = data.rarityLevels
    })
end

local function closeRarityMenu()
    if not rarityMenuOpen then
        return
    end

    rarityMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_plate_rarity:openMenu', openRarityMenu)

RegisterNetEvent('whellco_plate_rarity:closeMenu', closeRarityMenu)

RegisterNetEvent('whellco_plate_rarity:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('platerarity', function()
    TriggerServerEvent('whellco_plate_rarity:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_plate_rarity:closeMenu')
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
