local QBCore = exports['qb-core']:GetCoreObject()

local activeWar = nil

RegisterNetEvent('whellco_gang_territory:warStarted', function(data)
    activeWar = data

    QBCore.Functions.Notify(
        ('Turf war started at %s. %s vs %s.'):format(data.label, data.attackerGang, data.defenderGang),
        'primary',
        10000
    )
end)

RegisterNetEvent('whellco_gang_territory:warEnded', function(data)
    activeWar = nil

    QBCore.Functions.Notify(
        ('%s captured %s and earned $%d.'):format(data.winnerGang, data.territoryId, data.reward),
        'success',
        10000
    )
end)

RegisterCommand('territorystatus', function()
    if not activeWar then
        QBCore.Functions.Notify('No active turf war.', 'primary')
        return
    end

    local remaining = math.max(0, math.ceil((activeWar.endsAt - GetGameTimer()) / 1000))

    QBCore.Functions.Notify(
        ('%s: %s vs %s. %d second(s) remaining.'):format(
            activeWar.label,
            activeWar.attackerGang,
            activeWar.defenderGang,
            remaining
        ),
        'primary'
    )
end, false)