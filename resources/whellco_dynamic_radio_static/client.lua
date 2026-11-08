local QBCore = exports['qb-core']:GetCoreObject()

local radioEnabled = false

local function getNearestPlayerDistance()
    local players = GetActivePlayers()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local nearest = 999.0

    for _, player in ipairs(players) do
        local ped = GetPlayerPed(player)

        if ped ~= PlayerPedId() then
            local coords = GetEntityCoords(ped)
            local distance = #(playerCoords - coords)

            if distance < nearest then
                nearest = distance
            end
        end
    end

    return nearest
end

local function calculateStatic(distance)
    if distance <= Config.StaticStartDistance then
        return Config.MinStaticVolume
    end

    if distance >= Config.StaticMaxDistance then
        return Config.MaxStaticVolume
    end

    local range = Config.StaticMaxDistance - Config.StaticStartDistance
    local progress = (distance - Config.StaticStartDistance) / range

    return Config.MinStaticVolume + (progress * (Config.MaxStaticVolume - Config.MinStaticVolume))
end

CreateThread(function()
    while true do
        Wait(Config.UpdateInterval)

        if radioEnabled then
            local distance = getNearestPlayerDistance()
            local volume = calculateStatic(distance)

            SendNUIMessage({
                action = 'updateStatic',
                volume = volume
            })
        end
    end
end)

RegisterCommand('dynamicstatic', function()
    radioEnabled = not radioEnabled

    local PlayerData = QBCore.Functions.GetPlayerData()
    local channel = Config.RadioChannels[PlayerData.job.name]

    if radioEnabled and channel then
        exports['pma-voice']:setRadioChannel(channel)
    elseif not radioEnabled then
        exports['pma-voice']:setRadioChannel(0)
    end

    QBCore.Functions.Notify(radioEnabled and 'Dynamic radio static enabled.' or 'Dynamic radio static disabled.', 'primary')
end, false)

RegisterCommand('dynamicstaticinfo', function()
    QBCore.Functions.Notify('Use /dynamicstatic to enable distance-based radio static.', 'primary')
end, false)