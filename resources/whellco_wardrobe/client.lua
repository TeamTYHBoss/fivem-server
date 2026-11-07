local wardrobeOpen = false
local previewPed = nil

local models = {
    male = `mp_m_freemode_01`,
    female = `mp_f_freemode_01`
}

local function clearPreview()
    if previewPed then
        DeleteEntity(previewPed)
        previewPed = nil
    end
end

local function createPreviewPed(modelName)
    clearPreview()

    local model = models[modelName] or models.male

    RequestModel(model)

    while not HasModelLoaded(model) do
        Wait(10)
    end

    previewPed = CreatePed(4, model, 402.8664, -996.4108, -99.00027, 175.0, false, true)

    SetEntityInvincible(previewPed, true)
    FreezeEntityPosition(previewPed, true)
    SetBlockingOfNonTemporaryEvents(previewPed, true)

    SetModelAsNoLongerNeeded(model)

    return previewPed
end

local function applyAppearance(appearance)
    if not previewPed then
        return
    end

    local face = tonumber(appearance.faceShape) or 0
    local skin = tonumber(appearance.skinTone) or 0
    local hair = tonumber(appearance.hairStyle) or 0
    local hairColour = tonumber(appearance.hairColour) or 0

    SetPedHeadBlendData(previewPed, face, face, 0, skin, skin, 0, 0.5, 0.5, 0.0, false)
    SetPedComponentVariation(previewPed, 2, hair, hairColour, 0)

    SetPedComponentVariation(previewPed, 3, tonumber(appearance.torso) or 0, 0, 0)
    SetPedComponentVariation(previewPed, 8, tonumber(appearance.undershirt) or 0, 0, 0)
    SetPedComponentVariation(previewPed, 4, tonumber(appearance.legs) or 0, 0, 0)
    SetPedComponentVariation(previewPed, 6, tonumber(appearance.shoes) or 0, 0, 0)
end

local function openWardrobe()
    if wardrobeOpen then
        return
    end

    wardrobeOpen = true

    DoScreenFadeOut(500)
    Wait(500)

    createPreviewPed('male')

    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open' })

    DoScreenFadeIn(500)
end

RegisterNetEvent('whellco_wardrobe:open', openWardrobe)

RegisterNUICallback('changeModel', function(data, cb)
    if wardrobeOpen and data and models[data.model] then
        createPreviewPed(data.model)
        cb({ ok = true })
    else
        cb({ ok = false })
    end
end)

RegisterNUICallback('updateAppearance', function(data, cb)
    if wardrobeOpen and data then
        applyAppearance(data)
        cb({ ok = true })
    else
        cb({ ok = false })
    end
end)

RegisterNUICallback('confirm', function(data, cb)
    if not wardrobeOpen then
        cb({ ok = false })
        return
    end

    wardrobeOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })

    TriggerServerEvent('whellco_wardrobe:confirm', data or {})

    cb({ ok = true })
end)

RegisterNetEvent('whellco_wardrobe:confirmed', function(appearance)
    clearPreview()

    local model = models[appearance.model] or models.male

    RequestModel(model)

    while not HasModelLoaded(model) do
        Wait(10)
    end

    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)

    local ped = PlayerPedId()

    SetPedHeadBlendData(ped, appearance.faceShape or 0, appearance.faceShape or 0, 0,
        appearance.skinTone or 0, appearance.skinTone or 0, 0, 0.5, 0.5, 0.0, false)

    SetPedComponentVariation(ped, 2, appearance.hairStyle or 0, appearance.hairColour or 0, 0)
    SetPedComponentVariation(ped, 3, appearance.torso or 0, 0, 0)
    SetPedComponentVariation(ped, 8, appearance.undershirt or 0, 0, 0)
    SetPedComponentVariation(ped, 4, appearance.legs or 0, 0, 0)
    SetPedComponentVariation(ped, 6, appearance.shoes or 0, 0, 0)

    exports.spawnmanager:setAutoSpawn(false)

    exports.spawnmanager:spawnPlayer({
        x = 195.17,
        y = -933.77,
        z = 30.69,
        heading = 144.0
    })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        clearPreview()
        SetNuiFocus(false, false)
    end
end)
