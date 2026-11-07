local bankingMenuOpen = false

local function openBankingMenu(data)
    if bankingMenuOpen then
        return
    end

    bankingMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        balance = data.balance,
        transactions = data.transactions
    })
end

local function closeBankingMenu()
    if not bankingMenuOpen then
        return
    end

    bankingMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_banking:openMenu', openBankingMenu)

RegisterNetEvent('whellco_banking:closeMenu', closeBankingMenu)

RegisterNetEvent('whellco_banking:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('bank', function()
    TriggerServerEvent('whellco_banking:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_banking:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('deposit', function(data, cb)
    TriggerServerEvent('whellco_banking:deposit', data.amount)
    cb({ ok = true })
end)

RegisterNuiCallback('withdraw', function(data, cb)
    TriggerServerEvent('whellco_banking:withdraw', data.amount)
    cb({ ok = true })
end)

RegisterNuiCallback('transfer', function(data, cb)
    TriggerServerEvent('whellco_banking:transfer', data.targetId, data.amount)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
