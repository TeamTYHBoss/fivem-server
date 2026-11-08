local QBCore = exports['qb-core']:GetCoreObject()

local activeMinigame = false

local function startMinigame()
    if activeMinigame then
        return
    end

    activeMinigame = true

    local pins = {}

    for i = 1, Config.Minigame.pinCount do
        pins[i] = math.random(1, 4)
    end

    local attempts = 0
    local completed = 0

    CreateThread(function()
        local startTime = GetGameTimer()

        while activeMinigame do
            local elapsed = (GetGameTimer() - startTime) / 1000

            if elapsed >= Config.Minigame.duration then
                activeMinigame = false
                QBCore.Functions.Notify('Lockpicking failed: time expired.', 'error')
                break
            end

            Wait(100)
        end
    end)

    QBCore.Functions.Notify(
        ('Lockpicking started. Match %d pin(s) within %d seconds.'):format(
            Config.Minigame.pinCount,
            Config.Minigame.duration
        ),
        'primary'
    )

    CreateThread(function()
        while activeMinigame and completed < Config.Minigame.pinCount do
            Wait(0)

            if IsControlJustPressed(0, 38) then
                attempts = attempts + 1
                completed = completed + 1

                QBCore.Functions.Notify(
                    ('Pin %d/%d matched.'):format(completed, Config.Minigame.pinCount),
                    'success'
                )
            end

            if attempts >= Config.Minigame.maxAttempts then
                activeMinigame = false
                QBCore.Functions.Notify('Lockpicking failed: too many attempts.', 'error')
            end
        end

        if completed >= Config.Minigame.pinCount then
            activeMinigame = false
            QBCore.Functions.Notify('Lockpicking succeeded.', 'success')
            TriggerServerEvent('whellco_vehicle_theft:complete', GetEntityCoords(PlayerPedId()))
        end
    end)
end

RegisterCommand('lockpickvehicle', function()
    startMinigame()
end, false)

RegisterCommand('lockpickinfo', function()
    QBCore.Functions.Notify(
        ('Use /lockpickvehicle to start. Match %d pin(s) within %d seconds.'):format(
            Config.Minigame.pinCount,
            Config.Minigame.duration
        ),
        'primary'
    )
end, false)