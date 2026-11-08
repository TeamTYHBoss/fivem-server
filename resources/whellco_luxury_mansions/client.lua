local QBCore = exports['qb-core']:GetCoreObject()

local currentMansion = nil
local securityGuards = {}
local maids = {}
local cleanliness = 100

local function getMansion(id)
    for _, mansion in ipairs(Config.Mansions) do
        if mansion.id == id then
            return mansion
        end
    end

    return nil
end

local function clearStaff()
    for _, guard in ipairs(securityGuards) do
        if DoesEntityExist(guard) then
            DeletePed(guard)
        end
    end

    securityGuards = {}

    for _, maid in ipairs(maids) do
        if DoesEntityExist(maid) then
            DeletePed(maid)
        end
    end

    maids = {}
end

local function spawnSecurityGuards(mansion)
    local guardCount = mansion.maxSecurityGuards or 2

    for index = 1, guardCount do
        local offset = vector3(math.random(-10, 10), math.random(-10, 10), 0)
        local spawnCoords = mansion.interior + offset
        local guard = CreatePed(4, GetHashKey('s_m_m_security_01'), spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, true)

        if guard and guard ~= 0 then
            SetEntityAsMissionEntity(guard, true, true)
            SetPedArmour(guard, 50)
            GiveWeaponToPed(guard, GetHashKey('WEAPON_STUNGUN'), 1, false, true)
            SetPedFleeAttributes(guard, 0, false)
            SetPedCombatAttributes(guard, 46, true)

            securityGuards[#securityGuards + 1] = guard
        end
    end
end

local function spawnMaids(mansion)
    local maidCount = mansion.maxMaids or 2

    for index = 1, maidCount do
        local offset = vector3(math.random(-15, 15), math.random(-15, 15), 0)
        local spawnCoords = mansion.interior + offset
        local maid = CreatePed(4, GetHashKey('s_f_y_scrubs_01'), spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, true)

        if maid and maid ~= 0 then
            SetEntityAsMissionEntity(maid, true, true)
            maids[#maids + 1] = maid
        end
    end
end

local function patrolGuards()
    CreateThread(function()
        while currentMansion do
            Wait(5000)

            for _, guard in ipairs(securityGuards) do
                if DoesEntityExist(guard) then
                    local mansion = currentMansion
                    local patrolPoint = mansion.interior + vector3(math.random(-25, 25), math.random(-25, 25), 0)

                    TaskGoToCoordAnyMeans(guard, patrolPoint.x, patrolPoint.y, patrolPoint.z, 1.0, 0, false, 786603, 0)
                end
            end
        end
    end)
end

local function confrontIntruders()
    CreateThread(function()
        while currentMansion do
            Wait(1000)

            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)

            for _, guard in ipairs(securityGuards) do
                if DoesEntityExist(guard) then
                    local guardCoords = GetEntityCoords(guard)
                    local distance = #(playerCoords - guardCoords)

                    if distance <= 10.0 then
                        TaskGoToCoordAnyMeans(guard, playerCoords.x, playerCoords.y, playerCoords.z, 2.0, 0, false, 786603, 0)
                    end
                end
            end
        end
    end)
end

local function cleanMansion()
    CreateThread(function()
        while currentMansion do
            Wait(10000)

            if #maids > 0 then
                cleanliness = math.min(100, cleanliness + 5)
            else
                cleanliness = math.max(0, cleanliness - 2)
            end

            for _, maid in ipairs(maids) do
                if DoesEntityExist(maid) then
                    local mansion = currentMansion
                    local cleaningPoint = mansion.interior + vector3(math.random(-20, 20), math.random(-20, 20), 0)

                    TaskGoToCoordAnyMeans(maid, cleaningPoint.x, cleaningPoint.y, cleaningPoint.z, 1.0, 0, false, 786603, 0)
                end
            end
        end
    end)
end

local function drawMansionMarkers()
    CreateThread(function()
        while true do
            Wait(0)

            for _, mansion in ipairs(Config.Mansions) do
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = #(playerCoords - mansion.exterior)

                if distance < 20.0 then
                    QBCore.Functions.DrawText3D(
                        mansion.exterior.x,
                        mansion.exterior.y,
                        mansion.exterior.z,
                        ('[E] View %s - $%d'):format(mansion.label, mansion.price)
                    )

                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent('whellco_luxury_mansions:enter', mansion.id)
                    end
                end
            end
        end
    end)
end

RegisterNetEvent('whellco_luxury_mansions:enter', function(mansion)
    currentMansion = mansion
    cleanliness = 100

    DoScreenFadeOut(500)
    Wait(500)

    SetEntityCoords(PlayerPedId(), mansion.interior.x, mansion.interior.y, mansion.interior.z, false, false, false, false)
    SetEntityHeading(PlayerPedId(), mansion.heading)

    DoScreenFadeIn(500)

    spawnSecurityGuards(mansion)
    spawnMaids(mansion)
    patrolGuards()
    confrontIntruders()
    cleanMansion()

    QBCore.Functions.Notify(('Entered %s.'):format(mansion.label), 'success')
end)

RegisterNetEvent('whellco_luxury_mansions:openMenu', function()
    QBCore.Functions.Notify('Use mansion entrance markers to view or enter mansions.', 'primary')
end)

RegisterCommand('mansionhelp', function()
    QBCore.Functions.Notify('Use mansion entrance markers to view or enter mansions.', 'primary')
end, false)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    clearStaff()
end)

CreateThread(function()
    drawMansionMarkers()
end)