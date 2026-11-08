local QBCore = exports['qb-core']:GetCoreObject()

local currentLevel = 0
local searchBlips = {}

local function clearSearchAreas()
    for _, blip in ipairs(searchBlips) do
        RemoveBlip(blip)
    end

    searchBlips = {}
end

RegisterNetEvent('whellco_wanted_level:update', function(data)
    currentLevel = data.level or 0

    if currentLevel <= 0 then
        SetPlayerWantedLevel(PlayerId(), 0, false)
        SetPlayerWantedLevelNow(PlayerId(), false)
        clearSearchAreas()
        return
    end

    SetPlayerWantedLevel(PlayerId(), currentLevel, false)
    SetPlayerWantedLevelNow(PlayerId(), false)

    if data.response.aggressive then
        SetPoliceIgnorePlayer(PlayerId(), false)
        SetDispatchCopsForPlayer(PlayerId(), true)
    end

    QBCore.Functions.Notify(
        ('Wanted level %d: %s'):format(currentLevel, data.reason or 'active response'),
        'error',
        10000
    )
end)

RegisterNetEvent('whellco_wanted_level:searchArea', function(data)
    if not data or not data.coords then
        return
    end

    local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
    SetBlipSprite(blip, 161)
    SetBlipColour(blip, 1)
    SetBlipScale(blip, 1.5)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Last Known Position')
    EndTextCommandSetBlipName(blip)

    searchBlips[#searchBlips + 1] = blip

    SetTimeout(Config.Wanted.SearchConeDurationSeconds * 1000, function()
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end)
end)

RegisterNetEvent('whellco_wanted_level:clearSearch', function()
    clearSearchAreas()
end)

RegisterNetEvent('whellco_wanted_level:policeAlert', function(job, data)
    local Player = QBCore.Functions.GetPlayer(PlayerId())

    if not Player then
        return
    end

    local playerJob = Player.PlayerData.job

    if playerJob and Config.Wanted.PoliceAlertJobs[playerJob.name] then
        QBCore.Functions.Notify(
            ('Wanted suspect: level %d. Last known position updated.'):format(data.level),
            'error',
            10000
        )
    end
end)

RegisterNetEvent('whellco_wanted_level:militaryAlert', function(job, data)
    local Player = QBCore.Functions.GetPlayer(PlayerId())

    if not Player then
        return
    end

    local playerJob = Player.PlayerData.job

    if playerJob and Config.Wanted.MilitaryAlertJobs[playerJob.name] then
        QBCore.Functions.Notify(
            ('Military response authorised: wanted level %d.'):format(data.level),
            'error',
            10000
        )
    end
end)

RegisterCommand('wantedhelp', function()
    QBCore.Functions.Notify('Wanted levels escalate from 1 to 5 stars based on crime severity.', 'primary')
end, false)