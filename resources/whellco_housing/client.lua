local properties = {}
local nearbyProperty = nil
local ownedProperty = nil

local function drawHouseMarker(property)
    local coords = property.entrance

    DrawMarker(
        1,
        coords.x, coords.y, coords.z - 0.95,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        1.8, 1.8, 0.8,
        0, 190, 255, 110,
        false, true, 2, false, nil, nil, false
    )
end

CreateThread(function()
    while true do
        local sleep = 1000
        local pedCoords = GetEntityCoords(PlayerPedId())
        local closest = nil
        local closestDistance = 25.0

        for _, property in ipairs(properties) do
            local distance = #(pedCoords - property.entrance)

            if distance < closestDistance then
                closest = property
                closestDistance = distance
            end
        end

        if closest then
            sleep = 0
            drawHouseMarker(closest)

            if closestDistance <= 3.0 then
                nearbyProperty = closest

                BeginTextCommandDisplayHelp('STRING')
                AddTextComponentSubstringPlayerName(
                    closest.ownedByYou and 'Press ~INPUT_CONTEXT~ to enter your home'
                    or 'Press ~INPUT_CONTEXT~ to purchase this property'
                )
                EndTextCommandDisplayHelp(0, false, true, -1)

                if IsControlJustReleased(0, 38) then
                    if closest.ownedByYou then
                        TriggerServerEvent('whellco_housing:enter')
                    else
                        TriggerServerEvent('whellco_housing:purchase', closest.id)
                    end
                end
            end
        else
            nearbyProperty = nil
        end

        Wait(sleep)
    end
end)

RegisterNetEvent('whellco_housing:receiveProperties', function(data)
    properties = {}

    for _, property in ipairs(data.properties or {}) do
        properties[#properties + 1] = property
    end

    ownedProperty = data.ownedId
end)

RegisterNetEvent('whellco_housing:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message or '')
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterNetEvent('whellco_housing:teleport', function(coords, heading)
    local ped = PlayerPedId()

    DoScreenFadeOut(500)
    Wait(500)

    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityHeading(ped, heading or 0.0)

    Wait(500)
    DoScreenFadeIn(500)
end)
