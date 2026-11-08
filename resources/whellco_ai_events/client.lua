local activeEvent = nil

RegisterNetEvent('whellco_ai_events:announce', function(event)
    if not event or not event.coords then
        return
    end

    activeEvent = event

    QBCore.Functions.Notify(event.title or 'Dynamic event available', 'primary', 8000)
    QBCore.Functions.Notify(event.description or '', 'primary', 8000)
end)

RegisterCommand('aieventcomplete', function()
    if not activeEvent then
        QBCore.Functions.Notify('No active AI event.', 'error')
        return
    end

    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    if #(coords - activeEvent.coords) > 50.0 then
        QBCore.Functions.Notify('Return to the event area to complete it.', 'error')
        return
    end

    TriggerServerEvent('whellco_ai_events:complete', activeEvent.type)
    activeEvent = nil
end, false)