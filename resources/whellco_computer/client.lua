local QBCore = exports['qb-core']:GetCoreObject()

local computerOpen = false

local function openComputer()
    if computerOpen then
        return
    end

    computerOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open' })
end

local function closeComputer()
    if not computerOpen then
        return
    end

    computerOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

RegisterNetEvent('whellco_computer:open', openComputer)
RegisterCommand('computer', openComputer, false)

RegisterNUICallback('close', function(_, cb)
    closeComputer()
    cb('ok')
end)

RegisterNUICallback('escape', function(_, cb)
    closeComputer()
    cb('ok')
end)

local function requestCallback(name, data, cb)
    QBCore.Functions.TriggerCallback('whellco_computer:' .. name, function(result, message)
        if type(result) == 'table' then
            cb(result)
        else
            cb({ success = result, message = message })
        end
    end, data)
end

RegisterNUICallback('getBankBalance', function(_, cb)
    QBCore.Functions.TriggerCallback('whellco_computer:getBankBalance', function(balance)
        cb(balance or 0)
    end)
end)

RegisterNUICallback('getShop', function(_, cb)
    QBCore.Functions.TriggerCallback('whellco_computer:getShop', function(shop)
        cb(shop or {})
    end)
end)

RegisterNUICallback('buyItem', function(data, cb)
    QBCore.Functions.TriggerCallback('whellco_computer:buyItem', function(success, message)
        cb({ success = success, message = message })
    end, data.itemId)
end)

RegisterNUICallback('createListing', function(data, cb)
    requestCallback('createListing', data, cb)
end)

RegisterNUICallback('getMarketplace', function(_, cb)
    QBCore.Functions.TriggerCallback('whellco_computer:getMarketplace', function(listings)
        cb(listings or {})
    end)
end)

RegisterNUICallback('cancelListing', function(data, cb)
    requestCallback('cancelListing', data.listingId, cb)
end)

RegisterNUICallback('buyListing', function(data, cb)
    requestCallback('buyListing', data.listingId, cb)
end)

RegisterNUICallback('transferMoney', function(data, cb)
    requestCallback('transferMoney', data, cb)
end)

RegisterNUICallback('getTransfers', function(_, cb)
    QBCore.Functions.TriggerCallback('whellco_computer:getTransfers', function(transfers)
        cb(transfers or {})
    end)
end)

RegisterNUICallback('getNotifications', function(_, cb)
    QBCore.Functions.TriggerCallback('whellco_computer:getNotifications', function(notifications)
        cb(notifications or {})
    end)
end)

RegisterNUICallback('markNotificationRead', function(data, cb)
    requestCallback('markNotificationRead', data.notificationId, cb)
end)

RegisterNUICallback('createPost', function(data, cb)
    requestCallback('createPost', data.content, cb)
end)

RegisterNUICallback('getPosts', function(_, cb)
    QBCore.Functions.TriggerCallback('whellco_computer:getPosts', function(posts)
        cb(posts or {})
    end)
end)

RegisterNUICallback('addComment', function(data, cb)
    QBCore.Functions.TriggerCallback('whellco_computer:addComment', function(success, message)
        cb({ success = success, message = message })
    end, data.postId, data.content)
end)

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local nearComputer = false

        for _, computer in ipairs(Config.Computers) do
            if #(playerCoords - computer.coords) < 2.0 then
                nearComputer = true

                if not computerOpen then
                    QBCore.Functions.DrawText3D(computer.coords.x, computer.coords.y, computer.coords.z, '[E] Use Computer')
                end

                if IsControlJustReleased(0, 38) then
                    openComputer()
                end
            end
        end

        Wait(nearComputer and 0 or 500)
    end
end)

CreateThread(function()
    while true do
        if computerOpen and IsControlJustReleased(0, 200) then
            closeComputer()
        end

        Wait(0)
    end
end)