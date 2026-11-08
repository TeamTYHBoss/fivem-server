local QBCore = exports['qb-core']:GetCoreObject()

local restaurantPeds = {}

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

local function clearRestaurantPeds()
    for _, ped in ipairs(restaurantPeds) do
        if DoesEntityExist(ped) then
            DeletePed(ped)
        end
    end

    restaurantPeds = {}
end

local function spawnRestaurantCustomers(restaurant)
    clearRestaurantPeds()

    local customerCount = 4
    local seatOffsets = {
        vector3(1.5, 1.0, 0.0),
        vector3(-1.5, 1.0, 0.0),
        vector3(1.5, -1.0, 0.0),
        vector3(-1.5, -1.0, 0.0)
    }

    for index = 1, customerCount do
        local offset = seatOffsets[index] or vector3(0.0, 0.0, 0.0)
        local spawnCoords = restaurant.coords + offset
        local ped = CreatePed(4, GetHashKey('a_f_y_business_02'), spawnCoords.x, spawnCoords.y, spawnCoords.z, restaurant.heading, false, true)

        if ped and ped ~= 0 then
            SetEntityAsMissionEntity(ped, true, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            SetPedFleeAttributes(ped, 0, false)
            SetPedCanRagdollFromPlayerImpact(ped, false)

            TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_SEAT_WALL_EATING', 0, true)

            restaurantPeds[#restaurantPeds + 1] = ped
        end
    end
end

CreateThread(function()
    while true do
        Wait(1000)

        local playerCoords = GetEntityCoords(PlayerPedId())

        for _, restaurant in ipairs(Config.Restaurants) do
            local distance = #(playerCoords - restaurant.coords)

            if distance < 30.0 then
                if #restaurantPeds == 0 then
                    spawnRestaurantCustomers(restaurant)
                end
            elseif #restaurantPeds > 0 then
                clearRestaurantPeds()
            end

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

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    clearRestaurantPeds()
end)

RegisterCommand('foodhelp', function()
    QBCore.Functions.Notify('Walk up to a fast food restaurant and press E to view the menu.', 'primary')
end, false)