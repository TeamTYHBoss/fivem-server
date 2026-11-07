local characterMenuOpen = false
local selectedCharacter = nil

local function openCharacterMenu(data)
    if characterMenuOpen then
        return
    end

    characterMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        characters = data.characters,
        spawnPoints = data.spawnPoints,
        maxCharacters = data.maxCharacters
    })
end

RegisterNetEvent('whellco_characters:openMenu', openCharacterMenu)

RegisterNetEvent('whellco_characters:closeMenu', function()
    characterMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end)

RegisterNetEvent('whellco_characters:spawnCharacter', function(data)
    characterMenuOpen = false
    SetNuiFocus(false, false)

    SendNUIMessage({
        action = 'close'
    })

    DoScreenFadeOut(500)

    while not IsScreenFadedOut() do
        Wait(0)
    end

    local spawn = data.spawn

    RequestCollisionAtCoord(spawn.x, spawn.y, spawn.z)

    while not HasCollisionLoadedAroundEntity(PlayerPedId()) do
        Wait(0)
    end

    SetEntityCoords(PlayerPedId(), spawn.x, spawn.y, spawn.z, false, false, false, false)
    SetEntityHeading(PlayerPedId(), spawn.w or 0.0)

    Wait(500)
    DoScreenFadeIn(500)
end)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_characters:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('createCharacter', function(data, cb)
    TriggerServerEvent('whellco_characters:createCharacter', data)
    cb({ ok = true })
end)

RegisterNuiCallback('selectCharacter', function(data, cb)
    TriggerServerEvent('whellco_characters:selectCharacter', data.characterId)
    cb({ ok = true })
end)

RegisterNuiCallback('deleteCharacter', function(data, cb)
    TriggerServerEvent('whellco_characters:deleteCharacter', data.characterId)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
