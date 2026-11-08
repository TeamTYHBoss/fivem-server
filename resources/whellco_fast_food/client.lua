local QBCore = exports['qb-core']:GetCoreObject()

local restaurantPeds = {}
local cashierPed = nil
local heldFoodBag = nil
local heldItemId = nil
local canEat = false

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
    cashierPed = nil
end

local function clearHeldFoodBag()
    if heldFoodBag and DoesEntityExist(heldFoodBag) then
        DeleteEntity(heldFoodBag)
    end

    heldFoodBag = nil
    heldItemId = nil
    canEat = false
end

local function spawnCashier(restaurant)
    local cashierCoords = restaurant.coords + vector3(0.0, -1.5, 0.0)
    local cashier = CreatePed(4, GetHashKey('s_m_m_linecook'), cashierCoords.x, cashierCoords.y, cashierCoords.z, restaurant.heading, false, true)

    if cashier and cashier ~= 0 then
        SetEntityAsMissionEntity(cashier, true, true)
        SetBlockingOfNonTemporaryEvents(cashier, true)
        SetPedFleeAttributes(cashier, 0, false)
        SetPedCanRagdollFromPlayerImpact(cashier, false)

        TaskStartScenarioInPlace(cashier, 'WORLD_HUMAN_CLIPBOARD', 0, true)

        cashierPed = cashier
        restaurantPeds[#restaurantPeds + 1] = cashier
    end
end

local function eatFromBag()
    if not canEat or not heldItemId then
        return
    end

    local item = Config.Menu[heldItemId]

    if not item then
        return
    end

    TriggerServerEvent('whellco_fast_food:eat', heldItemId)

    QBCore.Functions.Notify(
        ('You ate %s and restored %d hunger.'):format(item.label, item.hunger),
        'success',
        5000
    )

    clearHeldFoodBag()
    ClearPedTasks(PlayerPedId())
end

local function handOverFoodBag(itemId)
    if not cashierPed or not DoesEntityExist(cashierPed) then
        return
    end

    local playerPed = PlayerPedId()
    local item = Config.Menu[itemId]

    if not item then
        return
    end

    ClearPedTasks(cashierPed)
    TaskTurnPedToFaceEntity(cashierPed, playerPed, 1500)
    Wait(500)

    clearHeldFoodBag()

    heldFoodBag = CreateObject(GetHashKey('prop_food_bag_01'), 0.0, 0.0, 0.0, true, true, false)

    if heldFoodBag and heldFoodBag ~= 0 then
        AttachEntityToEntity(
            heldFoodBag,
            playerPed,
            GetPedBoneIndex(playerPed, 57005),
            0.12,
            0.0,
            0.0,
            90.0,
            0.0,
            0.0,
            true,
            true,
            false,
            true,
            1,
            true
        )

        heldItemId = itemId
        canEat = true

        TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_STAND_IMPATIENT', 0, true)

        SetTimeout(10000, function()
            clearHeldFoodBag()
            ClearPedTasks(PlayerPedId())
        end)
    end

    TaskStartScenarioInPlace(cashierPed, 'WORLD_HUMAN_CLIPBOARD', 0, true)
end

local function spawnRestaurantCustomers(restaurant)
    clearRestaurantPeds()
    spawnCashier(restaurant)

    local customerCount = 3
    local seatOffsets = {
        vector3(1.5, 1.0, 0.0),
        vector3(-1.5, 1.0, 0.0),
        vector3(1.5, -1.0, 0.0)
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

    CreateThread(function()
        while #restaurantPeds > 0 do
            Wait(15000)

            local availableItems = getAvailableItems(restaurant.id)

            if #availableItems > 0 then
                local item = availableItems[math.random(#availableItems)]

                QBCore.Functions.Notify(
                    ('%s ordered %s.'):format(restaurant.label, item.label),
                    'primary',
                    5000
                )
            end
        end
    end)
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

        if canEat then
            QBCore.Functions.DrawText3D(
                playerCoords.x,
                playerCoords.y,
                playerCoords.z,
                '[G] Eat food from bag'
            )

            if IsControlJustReleased(0, 47) then
                eatFromBag()
            end
        end
    end
end)

RegisterNetEvent('whellco_fast_food:handOver', function(itemId)
    handOverFoodBag(itemId)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    clearRestaurantPeds()
    clearHeldFoodBag()
end)

RegisterCommand('foodhelp', function()
    QBCore.Functions.Notify('Walk up to a fast food restaurant and press E to view the menu.', 'primary')
end, false)