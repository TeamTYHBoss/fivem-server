local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_bartender_outfits:apply', function(data)
    if not data then
        return
    end

    local playerPed = PlayerPedId()
    local isMale = IsPedMale(playerPed)
    local outfit = isMale and data.outfit.male or data.outfit.female

    SetPedComponentVariation(playerPed, 11, outfit.torso, 0, 0)
    SetPedComponentVariation(playerPed, 4, outfit.pants, 0, 0)
    SetPedComponentVariation(playerPed, 6, outfit.shoes, 0, 0)

    QBCore.Functions.Notify(
        ('Applied bartender outfit: %s'):format(data.label),
        'success'
    )
end)

RegisterCommand('bartenderoutfitinfo', function()
    QBCore.Functions.Notify('Use /bartenderoutfit [outfit_id] to change your bartender outfit.', 'primary')
end, false)