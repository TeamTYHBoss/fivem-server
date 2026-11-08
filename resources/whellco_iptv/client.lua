local QBCore = exports['qb-core']:GetCoreObject()

local tvOpen = false
local currentChannel = 1
local channels = {}

local function loadChannels()
    channels = {}

    local playlist = Config.PlaylistUrl

    if not playlist then
        return
    end

    QBCore.Functions.TriggerCallback('whellco_iptv:getChannels', function(result)
        if not result or not result.channels then
            return
        end

        channels = result.channels
    end, playlist)
end

local function openTv()
    if tvOpen then
        return
    end

    tvOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        channels = channels,
        currentChannel = currentChannel
    })
end

local function closeTv()
    if not tvOpen then
        return
    end

    tvOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

local function nextChannel()
    if #channels == 0 then
        return
    end

    currentChannel = currentChannel + 1

    if currentChannel > #channels then
        currentChannel = 1
    end

    SendNUIMessage({
        action = 'setChannel',
        channel = channels[currentChannel]
    })
end

local function previousChannel()
    if #channels == 0 then
        return
    end

    currentChannel = currentChannel - 1

    if currentChannel < 1 then
        currentChannel = #channels
    end

    SendNUIMessage({
        action = 'setChannel',
        channel = channels[currentChannel]
    })
end

CreateThread(function()
    loadChannels()

    while true do
        Wait(0)

        local playerCoords = GetEntityCoords(PlayerPedId())
        local nearTv = false

        for _, tv in ipairs(Config.TVs) do
            local distance = #(playerCoords - tv.coords)

            if distance < Config.InteractDistance then
                nearTv = true

                QBCore.Functions.DrawText3D(
                    tv.coords.x,
                    tv.coords.y,
                    tv.coords.z,
                    '[E] Watch TV'
                )

                if IsControlJustReleased(0, Config.Controls.interact) then
                    openTv()
                end
            end
        end

        if tvOpen then
            if IsControlJustReleased(0, Config.Controls.nextChannel) then
                nextChannel()
            end

            if IsControlJustReleased(0, Config.Controls.previousChannel) then
                previousChannel()
            end

            if IsControlJustReleased(0, Config.Controls.closeTv) then
                closeTv()
            end
        end

        if not nearTv and tvOpen then
            closeTv()
        end
    end
end)

RegisterNUICallback('close', function()
    closeTv()
end)

RegisterNUICallback('nextChannel', function()
    nextChannel()
end)

RegisterNUICallback('previousChannel', function()
    previousChannel()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    closeTv()
end)