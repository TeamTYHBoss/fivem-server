local QBCore = exports['qb-core']:GetCoreObject()

local function getAvailableItems(restaurantId)
    local items = {}

    for itemId, item in pairs(Config.Menu) do
        for _, restaurant in ipairs(item.restaurants) do
            if restaurant == restaurantId then
                items[#items + 1] = {
                    id = itemId,
                    label = item.label,
                    price = item.price
                }
            end
        end
    end

    return items
end

CreateThread(function()
    while true do
        Wait(0)

        local playerCoords = GetEntityCoords(PlayerPedId())

        for _, restaurant in ipairs(Config.Restaurants) do
            local distance = #(playerCoords - restaurant.coords)

            if distance < 2.0 then
                QBCore.Functions.DrawText3D(
                    restaurant.coords.x,
                    restaurant.coords.y,
                    restaurant.coords.z,
                    ('[E] Order at %s'):format(restaurant.label)
                )

                if IsControlJustReleased(0, 38) then
                    local items = getAvailableItems(restaurant.id)
                    local menuText = 'Available: '

                    for index, item in ipairs(items) do
                        menuText = menuText .. ('%s ($%d)'):format(item.label, item.price)

                        if index < #items then
                            menuText = menuText .. ', '
                        end
                    end

                    QBCore.Functions.Notify(menuText, 'primary', 10000)
                end
            end
        end
    end
end)

RegisterCommand('foodhelp', function()
    QBCore.Functions.Notify('Walk up to a fast food restaurant and press E to view the menu.', 'primary')
end, false)