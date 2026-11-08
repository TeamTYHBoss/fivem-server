local QBCore = exports['qb-core']:GetCoreObject()

local currentInterior = nil
local loadedInteriors = {}

local function requestInterior(name)
    if loadedInteriors[name] then
        return true
    end

    RequestCollisionAtCoord(Config.Interiors[name].entry.x, Config.Interiors[name].entry.y, Config.Interiors[name].entry.z)

    local timeout = GetGameTimer() + 10000

    while not HasCollisionLoadedAroundEntity(PlayerPedId()) and GetGameTimer() < timeout do
        Wait(50)
    end

    loadedInteriors[name] = true

    return true
end

local function releaseInterior(name)
    if not loadedInteriors[name] then
        return
    end

    loadedInteriors[name] = nil
end

local function hasJobAccess(Player, interior)
    local requiredJob = interior.requiredJob

    if not requiredJob then
        return true
    end

    local job = Player.PlayerData.job

    return job and job.name == requiredJob and (job.grade.level or 0) >= (interior.jobGrade or 0)
end

local function hasInteractionAccess(Player, interaction)
    if not interaction.requiredJob then
        return true
    end

    local job = Player.PlayerData.job

    return job and job.name == interaction.requiredJob and (job.grade.level or 0) >= (interaction.jobGrade or 0)
end

CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local Player = QBCore.Functions.GetPlayerData()

        for id, interior in pairs(Config.Interiors) do
            local entryDistance = #(coords - interior.entry)
            local exitDistance = #(coords - interior.exit)

            if entryDistance < Config.LoadDistance and not loadedInteriors[id] then
                requestInterior(id)
            elseif entryDistance > Config.UnloadDistance and loadedInteriors[id] then
                releaseInterior(id)
            end

            if entryDistance < Config.InteractionDistance and hasJobAccess(Player, interior) then
                sleep = 0

                QBCore.Functions.DrawText3D(interior.entry.x, interior.entry.y, interior.entry.z, ('[E] Enter %s'):format(interior.label))

                if IsControlJustReleased(0, 38) then
                    SetEntityCoords(playerPed, interior.exit.x, interior.exit.y, interior.exit.z, false, false, false, false)
                    currentInterior = id
                end
            end

            if exitDistance < Config.InteractionDistance and currentInterior == id then
                sleep = 0

                QBCore.Functions.DrawText3D(interior.exit.x, interior.exit.y, interior.exit.z, ('[E] Exit %s'):format(interior.label))

                if IsControlJustReleased(0, 38) then
                    SetEntityCoords(playerPed, interior.entry.x, interior.entry.y, interior.entry.z, false, false, false, false)
                    currentInterior = nil
                end
            end

            for _, interaction in ipairs(Config.Interactions[id] or {}) do
                local distance = #(coords - interaction.coords)

                if distance < Config.InteractionDistance and hasInteractionAccess(Player, interaction) then
                    sleep = 0

                    QBCore.Functions.DrawText3D(interaction.coords.x, interaction.coords.y, interaction.coords.z, ('[E] %s'):format(interaction.label))

                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent('whellco_immersive_interiors:interact', id, interaction.id)
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

RegisterNetEvent('whellco_immersive_interiors:notify', function(message, type)
    QBCore.Functions.Notify(message, type or 'primary')
end)