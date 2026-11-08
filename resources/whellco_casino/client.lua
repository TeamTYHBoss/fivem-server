local casinoOpen = false
local activeNPCs = {}

local function createNPC(npcKey, npc)
    local model = GetHashKey(npc.model)

    RequestModel(model)

    local timeout = GetGameTimer() + 10000

    while not HasModelLoaded(model) and GetGameTimer() < timeout do
        Wait(50)
    end

    if not HasModelLoaded(model) then
        return
    end

    local ped = CreatePed(4, model, npc.coords.x, npc.coords.y, npc.coords.z - 1.0, npc.coords.w, false, true)

    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedDiesWhenInjured(ped, false)
    SetPedCanPlayAmbientAnims(ped, true)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)

    activeNPCs[npcKey] = ped

    SetModelAsNoLongerNeeded(model)
end

local function createBlip(coords, label, sprite, colour)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

    SetBlipSprite(blip, sprite or 620)
    SetBlipColour(blip, colour or 2)
    SetBlipScale(blip, 0.9)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(label)
    EndTextCommandSetBlipName(blip)

    return blip
end

CreateThread(function()
    for npcKey, npc in pairs(Config.NPCs) do
        createNPC(npcKey, npc)
    end

    createBlip(Config.Casino.entrance, 'WhellCo Casino', 620, 2)
    createBlip(Config.Penthouse.coords, 'Casino Penthouse', 475, 5)
end)

local function openCasino()
    if casinoOpen then
        return
    end

    TriggerServerEvent('whellco_casino:openMenu')
end

local function closeCasino()
    if not casinoOpen then
        return
    end

    casinoOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

RegisterNetEvent('whellco_casino:openMenu', function(data)
    casinoOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        data = data
    })
end)

RegisterNetEvent('whellco_casino:closeMenu', closeCasino)

RegisterNetEvent('whellco_casino:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterNetEvent('whellco_casino:slotResult', function(data)
    SendNUIMessage({
        action = 'slotResult',
        reels = data.reels,
        payout = data.payout,
        result = data.result
    })
end)

RegisterNetEvent('whellco_casino:wheelResult', function(data)
    SendNUIMessage({
        action = 'wheelResult',
        label = data.label,
        amount = data.amount
    })
end)

RegisterCommand('casino', function()
    openCasino()
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_casino:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('spinSlots', function(data, cb)
    TriggerServerEvent('whellco_casino:spinSlots', data.bet)
    cb({ ok = true })
end)

RegisterNuiCallback('spinWheel', function(_, cb)
    TriggerServerEvent('whellco_casino:spinWheel')
    cb({ ok = true })
end)

RegisterNuiCallback('purchaseMembership', function(data, cb)
    TriggerServerEvent('whellco_casino:purchaseMembership', data.tier)
    cb({ ok = true })
end)

RegisterNuiCallback('purchasePenthouse', function(_, cb)
    TriggerServerEvent('whellco_casino:purchasePenthouse')
    cb({ ok = true })
end)

RegisterNuiCallback('customisePenthouse', function(data, cb)
    TriggerServerEvent('whellco_casino:customisePenthouse', data.optionType, data.optionId)
    cb({ ok = true })
end)

RegisterNuiCallback('purchaseGarageSpace', function(data, cb)
    TriggerServerEvent('whellco_casino:purchaseGarageSpace', data.spaceType)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    SetNuiFocus(false, false)

    for _, ped in pairs(activeNPCs) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
end)
