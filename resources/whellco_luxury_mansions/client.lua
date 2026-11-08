local QBCore = exports['qb-core']:GetCoreObject()

local currentMansion = nil

local function drawMansionMarkers()
    CreateThread(function()
        while true do
            Wait(0)

            for _, mansion in ipairs(Config.Mansions) do
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = #(playerCoords - mansion.exterior)

                if distance < 20.0 then
                    QBCore.Functions.DrawText3D(
                        mansion.exterior.x,
                        mansion.exterior.y,
                        mansion.exterior.z,
                        ('[E] View %s - $%d'):format(mansion.label, mansion.price)
                    )

                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent('whellco_luxury_mansions:enter', mansion.id)
                    end
                end
            end
        end
    end)
end

RegisterNetEvent('whellco_luxury_mansions:enter', function(mansion)
    currentMansion = mansion

    DoScreenFadeOut(500)
    Wait(500)

    SetEntityCoords(PlayerPedId(), mansion.interior.x, mansion.interior.y, mansion.interior.z, false, false, false, false)
    SetEntityHeading(PlayerPedId(), mansion.heading)

    DoScreenFadeIn(500)

    QBCore.Functions.Notify(('Entered %s.'):format(mansion.label), 'success')
end)

RegisterNetEvent('whellco_luxury_mansions:openMenu', function()
    QBCore.Functions.Notify('Use mansion entrance markers to view or enter mansions.', 'primary')
end)

RegisterCommand('mansionhelp', function()
    QBCore.Functions.Notify('Use mansion entrance markers to view or enter mansions.', 'primary')
end, false)

CreateThread(function()
    drawMansionMarkers()
end)