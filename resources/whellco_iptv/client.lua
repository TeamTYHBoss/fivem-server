local QBCore = exports['qb-core']:GetCoreObject()

local tvOpen = false
local currentTv = nil
local currentChannel = 1
local channels = {}
local hasRemote = false
local remoteProp = nil
local remoteFound = false

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

local function clearRemoteProp()
    if remoteProp and DoesEntityExist(remoteProp) then
        DeleteEntity(remoteProp)
    end

    remoteProp = nil
end

local function spawnRemoteProp()
    clearRemoteProp()

    local house = Config.Houses[1]

    if not house then
        return
    end

    local spawnPoint = house.remoteSpawnPoints[math.random(#house.remoteSpawnPoints)]
    local prop = CreateObject(GetHashKey('prop_remote_control'), spawnPoint.x, spawnPoint.y, spawnPoint.z, true, true, false)

    if prop and prop ~= 0 then
        SetEntityAsMissionEntity(prop, true, true)
        PlaceObjectOnGroundProperly(prop)
        remoteProp = prop
    end
end

local function openTv(tv)
    if tvOpen then
        return
    end

    if not hasRemote then
        QBCore.Functions.Notify('You need to find the TV remote somewhere in the house.', 'error')
        return
    end

    currentTv = tv
    tvOpen = true

    QBCore.Functions.TriggerCallback('whellco_iptv:getLastChannel', function(result)
        if result and result.channel then
            currentChannel = result.channel
        end

        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'open',
            channels = channels,
            currentChannel = currentChannel
        })
    end, tv.id)
end

local function closeTv()
    if not tvOpen then
        return
    end

    tvOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })

    if currentTv then
        TriggerServerEvent('whellco_iptv:saveChannel', currentTv.id, currentChannel)
    end
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
    spawnRemoteProp()

    while true do
        Wait(0)

        local playerCoords = GetEntityCoords(PlayerPedId())
        local nearTv = false
        local nearHouse = false

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
                    openTv(tv)
                end
            end
        end

        for _, house in ipairs(Config.Houses) do
            local distance = #(playerCoords - house.center)

            if distance < house.radius then
                nearHouse = true
            end
        end

        if remoteProp and DoesEntityExist(remoteProp) then
            local remoteCoords = GetEntityCoords(remoteProp)
            local remoteDistance = #(playerCoords - remoteCoords)

            if remoteDistance < Config.RemoteHintDistance then
                QBCore.Functions.DrawText3D(
                    remoteCoords.x,
                    remoteCoords.y,
                    remoteCoords.z,
                    'TV remote nearby'
                )
            end

            if remoteDistance < 1.5 then
                QBCore.Functions.DrawText3D(
                    remoteCoords.x,
                    remoteCoords.y,
                    remoteCoords.z,
                    '[E] Pick up TV remote'
                )

                if IsControlJustReleased(0, Config.Controls.interact) then
                    TriggerServerEvent('whellco_iptv:pickUpRemote')
                    clearRemoteProp()
                    remoteFound = true
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

        if not nearHouse and remoteFound then
            TriggerServerEvent('whellco_iptv:dropRemote')
            remoteFound = false
            hasRemote = false
            spawnRemoteProp()
        end
    end
end)

RegisterNetEvent('whellco_iptv:remoteStatus', function(status)
    hasRemote = status
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

    clearRemoteProp()
    closeTv()
end)