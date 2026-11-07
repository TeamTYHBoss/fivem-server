local shopOpen = false

local function openShop(data)
    if shopOpen then
        return
    end

    shopOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        shop = data
    })
end

RegisterNetEvent('whellco_economy:openShop', openShop)

RegisterNetEvent('whellco_economy:updateAccount', function(account)
    SendNUIMessage({
        action = 'updateAccount',
        account = account
    })
end)

RegisterNetEvent('whellco_economy:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterNetEvent('whellco_economy:levelUp', function(level)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(('Level up! You are now level %d.'):format(level))
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('shop', function()
    TriggerServerEvent('whellco_economy:openShop', 'legion_247')
end, false)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
