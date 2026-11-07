local locations = {
    {
        id = 'legion_square',
        label = 'Legion Square',
        description = 'Central Los Santos, close to shops and transport.',
        coords = vector3(195.17, -933.77, 30.69),
        heading = 144.0
    },
    {
        id = 'paleto_bay',
        label = 'Paleto Bay',
        description = 'A quiet coastal town in the north of Blaine County.',
        coords = vector3(-447.89, 6013.60, 31.72),
        heading = 42.0
    },
    {
        id = 'sandy_shores',
        label = 'Sandy Shores',
        description = 'A desert town beside the Alamo Sea.',
        coords = vector3(1962.31, 3740.70, 32.34),
        heading = 300.0
    },
    {
        id = 'grapeseed',
        label = 'Grapeseed',
        description = 'Rural farmland in the north-east of the map.',
        coords = vector3(1701.49, 4924.28, 42.06),
        heading = 20.0
    }
}

local selectorOpen = false

local function openSelector()
    if selectorOpen then
        return
    end

    selectorOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        locations = locations
    })
end

RegisterNetEvent('whellco_spawn_selector:open', openSelector)

RegisterNUICallback('selectSpawn', function(data, cb)
    local selectedId = data and data.id
    local selected = nil

    for _, location in ipairs(locations) do
        if location.id == selectedId then
            selected = location
            break
        end
    end

    if not selected then
        cb({ ok = false, error = 'Invalid spawn location' })
        return
    end

    selectorOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })

    exports.spawnmanager:setAutoSpawn(false)

    exports.spawnmanager:spawnPlayer({
        x = selected.coords.x,
        y = selected.coords.y,
        z = selected.coords.z,
        heading = selected.heading
    }, function()
        TriggerEvent('whellco_spawn_selector:spawned', selected.id)
    end)

    cb({ ok = true })
end)

RegisterNUICallback('close', function(_, cb)
    selectorOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })

    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
