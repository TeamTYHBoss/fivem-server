local insuranceMenuOpen = false

local function openInsuranceMenu(data)
    if insuranceMenuOpen then
        return
    end

    insuranceMenuOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        plans = data.plans,
        policies = data.policies,
        claims = data.claims
    })
end

local function closeInsuranceMenu()
    if not insuranceMenuOpen then
        return
    end

    insuranceMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNetEvent('whellco_insurance:openMenu', openInsuranceMenu)

RegisterNetEvent('whellco_insurance:closeMenu', closeInsuranceMenu)

RegisterNetEvent('whellco_insurance:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterCommand('insurance', function()
    TriggerServerEvent('whellco_insurance:openMenu')
end, false)

RegisterNuiCallback('closeMenu', function(_, cb)
    TriggerServerEvent('whellco_insurance:closeMenu')
    cb({ ok = true })
end)

RegisterNuiCallback('buyPolicy', function(data, cb)
    TriggerServerEvent('whellco_insurance:buyPolicy', data.vehicleId, data.plan)
    cb({ ok = true })
end)

RegisterNuiCallback('cancelPolicy', function(data, cb)
    TriggerServerEvent('whellco_insurance:cancelPolicy', data.policyId)
    cb({ ok = true })
end)

RegisterNuiCallback('submitClaim', function(data, cb)
    TriggerServerEvent('whellco_insurance:submitClaim', data.policyId, data.damageAmount)
    cb({ ok = true })
end)

RegisterNuiCallback('repairVehicle', function(data, cb)
    TriggerServerEvent('whellco_insurance:repairVehicle', data.vehicleId, data.repairCost)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
