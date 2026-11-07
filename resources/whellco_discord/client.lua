local discordMenuOpen = false

local function openDiscordMenu(data)
    if discordMenuOpen then
        return
    end

    discordMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        roles = data.roles,
        logs = data.logs
    })
end

local function closeDiscordMenu()
    if not discordMenuOpen then
        return
    end

    discordMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_discord:openMenu', openDiscordMenu)

RegisterNetEvent('whellco_discord:closeMenu', closeDiscordMenu)

RegisterNetEvent('whellco_discord:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('discord', function()
    TriggerServerEvent('whellco_discord:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_discord:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('linkDiscord', function(data, cb)
    TriggerServerEvent('whellco_discord:linkDiscord', data.discordId)
    cb({ ok = true })
end)

RegisterNuiCallback('unlinkDiscord', function(data, cb)
    TriggerServerEvent('whellco_discord:unlinkDiscord', data.discordId)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
