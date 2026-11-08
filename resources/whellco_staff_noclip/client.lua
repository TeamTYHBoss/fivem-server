local QBCore = exports['qb-core']:GetCoreObject()

local noclipEnabled = false

RegisterNetEvent('whellco_staff_noclip:toggle', function()
    noclipEnabled = not noclipEnabled

    local playerPed = PlayerPedId()

    SetEntityCollision(playerPed, not noclipEnabled, true)
    SetEntityInvincible(playerPed, noclipEnabled)

    QBCore.Functions.Notify(
        noclipEnabled and 'Noclip enabled. Use movement keys to fly.' or 'Noclip disabled.',
        noclipEnabled and 'success' or 'primary'
    )
end)

CreateThread(function()
    while true do
        Wait(0)

        if noclipEnabled then
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local forward = GetEntityForwardVector(playerPed)
            local speed = Config.Noclip.speed

            if IsControlPressed(0, 21) then
                speed = Config.Noclip.fastSpeed
            end

            if IsControlPressed(0, 32) then
                coords = coords + forward * speed
            end

            if IsControlPressed(0, 33) then
                coords = coords - forward * speed
            end

            if IsControlPressed(0, 34) then
                coords = coords - GetEntityRightVector(playerPed) * speed
            end

            if IsControlPressed(0, 35) then
                coords = coords + GetEntityRightVector(playerPed) * speed
            end

            if IsControlPressed(0, 22) then
                coords = coords + vector3(0.0, 0.0, speed)
            end

            if IsControlPressed(0, 36) then
                coords = coords - vector3(0.0, 0.0, speed)
            end

            SetEntityCoords(playerPed, coords.x, coords.y, coords.z, false, false, false, false)
        else
            Wait(250)
        end
    end
end)

RegisterCommand('noclipinfo', function()
    QBCore.Functions.Notify('Use /noclip to toggle staff noclip mode.', 'primary')
end, false)