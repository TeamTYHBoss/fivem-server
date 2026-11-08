local QBCore = exports['qb-core']:GetCoreObject()

local function createPed(data)
    local model = GetHashKey(data.model)

    RequestModel(model)

    while not HasModelLoaded(model) do
        Wait(10)
    end

    local ped = CreatePed(4, model, data.coords.x, data.coords.y, data.coords.z, data.coords.w, false, true)

    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatAttributes(ped, 46, true)
    FreezeEntityPosition(ped, true)
    TaskStartScenarioInPlace(ped, data.scenario, 0, true)
end

CreateThread(function()
    for _, furniture in ipairs(Config.Furniture) do
        local model = GetHashKey(furniture.model)

        RequestModel(model)

        while not HasModelLoaded(model) do
            Wait(10)
        end

        local object = CreateObject(model, furniture.coords.x, furniture.coords.y, furniture.coords.z, false, false, false)

        SetEntityCoords(object, furniture.coords.x, furniture.coords.y, furniture.coords.z)
        SetEntityHeading(object, furniture.coords.w)
        FreezeEntityPosition(object, true)
    end

    for _, npc in pairs(Config.NPCs) do
        createPed(npc)
    end
end)

RegisterCommand('stripclubinfo', function()
    QBCore.Functions.Notify(
        ('%s is open. Use /stripclub for drinks and /tipdancer to tip.'):format(Config.StripClub.label),
        'primary'
    )
end, false)