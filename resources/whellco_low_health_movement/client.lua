local QBCore = exports['qb-core']:GetCoreObject()

local currentRate = Config.NormalMovementRate

local function setMovementRate(rate)
    if rate == currentRate then
        return
    end

    currentRate = rate
    SetPedMoveRateOverride(PlayerPedId(), rate)
end

CreateThread(function()
    while true do
        Wait(Config.CheckInterval)

        local playerPed = PlayerPedId()
        local health = GetEntityHealth(playerPed)

        if health <= 0 then
            setMovementRate(Config.NormalMovementRate)
        elseif health <= Config.CriticalHealthThreshold then
            setMovementRate(Config.CriticalMovementRate)
        elseif health <= Config.LowHealthThreshold then
            setMovementRate(Config.InjuredMovementRate)
        else
            setMovementRate(Config.NormalMovementRate)
        end
    end
end)

RegisterCommand('movementinfo', function()
    QBCore.Functions.Notify(
        ('Movement slows below %d health and becomes critical below %d health.'):format(
            Config.LowHealthThreshold,
            Config.CriticalHealthThreshold
        ),
        'primary'
    )
end, false)