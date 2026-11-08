local QBCore = exports['qb-core']:GetCoreObject()

local function isAdmin(Player)
    local job = Player.PlayerData.job

    return job and Config.AdminJobs[job.name]
end

local function getMansion(id)
    for _, mansion in ipairs(Config.Mansions) do
        if mansion.id == id then
            return mansion
        end
    end

    return nil
end

local function isOwner(Player, mansionId)
    local ownership = MySQL.single.await(
        'SELECT owner_citizenid FROM whellco_mansion_ownership WHERE mansion_id = ?',
        {
            mansionId
        }
    )

    return ownership and ownership.owner_citizenid == Player.PlayerData.citizenid
end

RegisterNetEvent('whellco_luxury_mansions:purchase', function(mansionId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local mansion = getMansion(mansionId)

    if not Player or not mansion then
        return
    end

    local owned = MySQL.scalar.await(
        'SELECT COUNT(*) FROM whellco_mansion_ownership WHERE mansion_id = ?',
        {
            mansion.id
        }
    )

    if owned and owned > 0 then
        TriggerClientEvent('QBCore:Notify', source, 'This mansion is already owned.', 'error')
        return
    end

    if Player.PlayerData.money.bank < mansion.price then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have enough money in your bank account.', 'error')
        return
    end

    Player.Functions.RemoveMoney('bank', mansion.price, 'mansion-purchase')

    MySQL.insert.await(
        [[INSERT INTO whellco_mansion_ownership
            (mansion_id, owner_citizenid, purchase_price)
          VALUES (?, ?, ?)]],
        {
            mansion.id,
            Player.PlayerData.citizenid,
            mansion.price
        }
    )

    TriggerClientEvent('QBCore:Notify', source, ('Purchased %s for $%d.'):format(mansion.label, mansion.price), 'success')
end)

RegisterNetEvent('whellco_luxury_mansions:enter', function(mansionId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local mansion = getMansion(mansionId)

    if not Player or not mansion then
        return
    end

    local ownership = MySQL.single.await(
        'SELECT owner_citizenid FROM whellco_mansion_ownership WHERE mansion_id = ?',
        {
            mansion.id
        }
    )

    if not ownership then
        TriggerClientEvent('QBCore:Notify', source, 'This mansion is not owned.', 'error')
        return
    end

    local allowed = ownership.owner_citizenid == Player.PlayerData.citizenid

    if not allowed then
        local guest = MySQL.scalar.await(
            'SELECT COUNT(*) FROM whellco_mansion_guests WHERE mansion_id = ? AND guest_citizenid = ?',
            {
                mansion.id,
                Player.PlayerData.citizenid
            }
        )

        allowed = guest and guest > 0
    end

    if not allowed then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have access to this mansion.', 'error')
        return
    end

    TriggerClientEvent('whellco_luxury_mansions:enter', source, mansion)
end)

RegisterNetEvent('whellco_luxury_mansions:guest:add', function(mansionId, guestCitizenId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local mansion = getMansion(mansionId)

    if not Player or not mansion or not isOwner(Player, mansionId) then
        return
    end

    local guestCount = MySQL.scalar.await(
        'SELECT COUNT(*) FROM whellco_mansion_guests WHERE mansion_id = ?',
        {
            mansion.id
        }
    )

    if guestCount >= mansion.maxGuests then
        TriggerClientEvent('QBCore:Notify', source, 'Guest list is full.', 'error')
        return
    end

    MySQL.insert.await(
        [[INSERT INTO whellco_mansion_guests
            (mansion_id, guest_citizenid, added_by)
          VALUES (?, ?, ?)]],
        {
            mansion.id,
            guestCitizenId,
            Player.PlayerData.citizenid
        }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Guest added to mansion access list.', 'success')
end)

RegisterNetEvent('whellco_luxury_mansions:guest:remove', function(mansionId, guestCitizenId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local mansion = getMansion(mansionId)

    if not Player or not mansion or not isOwner(Player, mansionId) then
        return
    end

    MySQL.query.await(
        'DELETE FROM whellco_mansion_guests WHERE mansion_id = ? AND guest_citizenid = ?',
        {
            mansion.id,
            guestCitizenId
        }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Guest removed from mansion access list.', 'success')
end)

RegisterNetEvent('whellco_luxury_mansions:staff:hire', function(mansionId, staffType)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local mansion = getMansion(mansionId)
    local staffConfig = Config.Staff[staffType]

    if not Player or not mansion or not staffConfig or not isOwner(Player, mansionId) then
        return
    end

    local staffCount = MySQL.scalar.await(
        'SELECT COUNT(*) FROM whellco_mansion_staff WHERE mansion_id = ? AND staff_type = ?',
        {
            mansion.id,
            staffType
        }
    )

    if staffCount >= staffConfig.maxPerMansion then
        TriggerClientEvent('QBCore:Notify', source, 'Staff limit reached for this role.', 'error')
        return
    end

    if Player.PlayerData.money.bank < staffConfig.hiringCost then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have enough money to hire staff.', 'error')
        return
    end

    Player.Functions.RemoveMoney('bank', staffConfig.hiringCost, 'mansion-staff-hire')

    MySQL.insert.await(
        [[INSERT INTO whellco_mansion_staff
            (mansion_id, owner_citizenid, staff_type, hourly_wage)
          VALUES (?, ?, ?, ?)]],
        {
            mansion.id,
            Player.PlayerData.citizenid,
            staffType,
            staffConfig.hourlyWage
        }
    )

    TriggerClientEvent('QBCore:Notify', source, ('Hired %s for $%d.'):format(staffConfig.label, staffConfig.hiringCost), 'success')
end)

RegisterNetEvent('whellco_luxury_mansions:staff:fire', function(mansionId, staffId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local mansion = getMansion(mansionId)

    if not Player or not mansion or not isOwner(Player, mansionId) then
        return
    end

    MySQL.query.await(
        'DELETE FROM whellco_mansion_staff WHERE id = ? AND mansion_id = ?',
        {
            staffId,
            mansion.id
        }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Staff member dismissed.', 'success')
end)

RegisterNetEvent('whellco_luxury_mansions:event:create', function(mansionId, eventName, durationMinutes)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local mansion = getMansion(mansionId)

    if not Player or not mansion or not isOwner(Player, mansionId) then
        return
    end

    durationMinutes = math.Clamp(tonumber(durationMinutes) or 60, 15, 240)

    MySQL.insert.await(
        [[INSERT INTO whellco_mansion_events
            (mansion_id, host_citizenid, event_name, ends_at)
          VALUES (?, ?, ?, ?)]],
        {
            mansion.id,
            Player.PlayerData.citizenid,
            eventName,
            os.time() + (durationMinutes * 60)
        }
    )

    TriggerClientEvent('QBCore:Notify', source, ('Private event created: %s.'):format(eventName), 'success')
end)

RegisterNetEvent('whellco_luxury_mansions:event:end', function(mansionId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local mansion = getMansion(mansionId)

    if not Player or not mansion or not isOwner(Player, mansionId) then
        return
    end

    MySQL.query.await(
        'DELETE FROM whellco_mansion_events WHERE mansion_id = ?',
        {
            mansion.id
        }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Private event ended.', 'success')
end)

RegisterNetEvent('whellco_luxury_mansions:cctv:add', function(mansionId, cameraName, coords)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local mansion = getMansion(mansionId)

    if not Player or not mansion or not isOwner(Player, mansionId) then
        return
    end

    local cameraCount = MySQL.scalar.await(
        'SELECT COUNT(*) FROM whellco_mansion_cameras WHERE mansion_id = ?',
        {
            mansion.id
        }
    )

    if cameraCount >= mansion.maxCameras then
        TriggerClientEvent('QBCore:Notify', source, 'Camera limit reached.', 'error')
        return
    end

    MySQL.insert.await(
        [[INSERT INTO whellco_mansion_cameras
            (mansion_id, owner_citizenid, camera_name, coords_x, coords_y, coords_z)
          VALUES (?, ?, ?, ?, ?, ?)]],
        {
            mansion.id,
            Player.PlayerData.citizenid,
            cameraName,
            coords.x,
            coords.y,
            coords.z
        }
    )

    TriggerClientEvent('QBCore:Notify', source, 'CCTV camera installed.', 'success')
end)

RegisterNetEvent('whellco_luxury_mansions:cctv:remove', function(mansionId, cameraId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local mansion = getMansion(mansionId)

    if not Player or not mansion or not isOwner(Player, mansionId) then
        return
    end

    MySQL.query.await(
        'DELETE FROM whellco_mansion_cameras WHERE id = ? AND mansion_id = ?',
        {
            cameraId,
            mansion.id
        }
    )

    TriggerClientEvent('QBCore:Notify', source, 'CCTV camera removed.', 'success')
end)

RegisterNetEvent('whellco_luxury_mansions:customise', function(mansionId, setting, value)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local mansion = getMansion(mansionId)

    if not Player or not mansion or not isOwner(Player, mansionId) then
        return
    end

    if setting ~= 'wall_colour' and setting ~= 'floor_style' and setting ~= 'lighting_mode' then
        return
    end

    MySQL.update.await(
        ('UPDATE whellco_mansion_ownership SET %s = ? WHERE mansion_id = ?'):format(setting),
        {
            value,
            mansion.id
        }
    )

    TriggerClientEvent('QBCore:Notify', source, 'Mansion customisation updated.', 'success')
end)

RegisterNetEvent('whellco_luxury_mansions:sellback', function(mansionId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local mansion = getMansion(mansionId)

    if not Player or not mansion or not isOwner(Player, mansionId) then
        return
    end

    local sellbackAmount = math.floor(mansion.price * (mansion.sellbackPercent / 100))

    MySQL.query.await(
        'DELETE FROM whellco_mansion_ownership WHERE mansion_id = ?',
        {
            mansion.id
        }
    )

    MySQL.query.await(
        'DELETE FROM whellco_mansion_guests WHERE mansion_id = ?',
        {
            mansion.id
        }
    )

    MySQL.query.await(
        'DELETE FROM whellco_mansion_events WHERE mansion_id = ?',
        {
            mansion.id
        }
    )

    MySQL.query.await(
        'DELETE FROM whellco_mansion_cameras WHERE mansion_id = ?',
        {
            mansion.id
        }
    )

    MySQL.query.await(
        'DELETE FROM whellco_mansion_staff WHERE mansion_id = ?',
        {
            mansion.id
        }
    )

    Player.Functions.AddMoney('bank', sellbackAmount, 'mansion-sellback')

    TriggerClientEvent('QBCore:Notify', source, ('Sold %s back to the state for $%d.'):format(mansion.label, sellbackAmount), 'success')
end)

RegisterCommand('mansions', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    TriggerClientEvent('whellco_luxury_mansions:openMenu', source)
end, false)

RegisterCommand('mansionadmin', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or not isAdmin(Player) then
        return
    end

    TriggerClientEvent('QBCore:Notify', source, 'Luxury mansion system is active.', 'primary')
end, false)