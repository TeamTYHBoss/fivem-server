local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_lockpick_crafting:startCrafting', function(data)
    if not data then
        return
    end

    QBCore.Functions.Progressbar('crafting_lockpick', ('Crafting %s...'):format(data.label), data.duration * 1000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
    }, {}, {}, {}, function()
        TriggerServerEvent('whellco_lockpick_crafting:complete', data.recipeId)
    end, function()
        QBCore.Functions.Notify('Crafting cancelled.', 'error')
    end)
end)

RegisterNetEvent('whellco_lockpick_crafting:crafted', function(data)
    if not data then
        return
    end

    QBCore.Functions.Notify(
        ('Crafted %dx %s.'):format(data.amount, data.label),
        'success'
    )
end)

RegisterCommand('craftinfo', function()
    QBCore.Functions.Notify('Use /craftlockpick lockpick or /craftlockpick advanced_lockpick at the workbench.', 'primary')
end, false)