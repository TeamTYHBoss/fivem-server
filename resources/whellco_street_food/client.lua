local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_street_food:start', function(data)
    if not data then
        return
    end

    QBCore.Functions.Notify(
        ('Preparing %s. Complete the cooking steps.'):format(data.food.label),
        'primary',
        10000
    )

    Wait(data.duration * 1000)

    local score = math.random(40, 100)

    TriggerServerEvent('whellco_street_food:complete', data.food.label, data.food.reward, score)
end)

RegisterCommand('streetfoodinfo', function()
    QBCore.Functions.Notify('Use /streetfood [food_id] to order from the street food vendor.', 'primary')
end, false)