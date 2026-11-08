local QBCore = exports['qb-core']:GetCoreObject()

local computerOpen = false

local function openComputer()
    if computerOpen then
        return
    end

    computerOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open'
    })
end

local function closeComputer()
    if not computerOpen then
        return
    end

    computerOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_computer:open', openComputer)

RegisterNUICallback('close', function(_, cb)
    closeComputer()
    cb('ok')
end)

RegisterNUICallback('getBankBalance', function(_, cb)
    QBCore.Functions.TriggerCallback('whellco_computer:getBankBalance', function(balance)
        cb(balance or 0)
    end)
end)

RegisterNUICallback('buyItem', function(data, cb)
    QBCore.Functions.TriggerCallback('whellco_computer:buyItem', function(success, message)
        cb({
            success = success,
            message = message
        })
    end, data.itemId)
end)

RegisterNUICallback('createPost', function(data, cb)
    QBCore.Functions.TriggerCallback('whellco_computer:createPost', function(success, message)
        cb({
            success = success,
            message = message
        })
    end, data.content)
end)

RegisterNUICallback('getPosts', function(_, cb)
    QBCore.Functions.TriggerCallback('whellco_computer:getPosts', function(posts)
        cb(posts or {})
    end)
end)

RegisterNUICallback('addComment', function(data, cb)
    QBCore.Functions.TriggerCallback('whellco_computer:addComment', function(success, message)
        cb({
            success = success,
            message = message
        })
    end, data.postId, data.content)
end)

CreateThread(function()
    while true do
        Wait(0)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local nearComputer = false

        for _, computer in ipairs(Config.Computers) do
            local distance = #(playerCoords - computer.coords)

            if distance < 2.0 then
                nearComputer = true

                if not computerOpen then
                    QBCore.Functions.DrawText3D(computer.coords.x, computer.coords.y, computer.coords.z, '[E] Use Computer')
                end

                if IsControlJustReleased(0, 38) then
                    openComputer()
                end
            end
        end

        if not nearComputer and computerOpen then
            closeComputer()
        end
    end
end)