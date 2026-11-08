local QBCore = exports['qb-core']:GetCoreObject()

local currentAnimation = nil

local Animations = {
    walk = {
        { label = 'Confident', dict = 'move_m@confident', anim = 'walk' },
        { label = 'Business', dict = 'move_m@business@a', anim = 'walk' },
        { label = 'Casual', dict = 'move_m@generic', anim = 'walk' },
        { label = 'Gangster', dict = 'move_m@gangster@a', anim = 'walk' },
        { label = 'Tough', dict = 'move_m@tough_guy@', anim = 'walk' }
    },
    smoking = {
        { label = 'Smoke', dict = 'amb@world_human_smoking@male@male_a/base', anim = 'base' }
    },
    drinking = {
        { label = 'Drink', dict = 'amb@world_human_drinking@male@male_a/base', anim = 'base' }
    },
    gestures = {
        { label = 'Wave', dict = 'mp_ped_interaction', anim = 'handshake_gf_a' },
        { label = 'Facepalm', dict = 'anim@mp_player_intselfiethe_bird', anim = 'idle_a' },
        { label = 'Thumbs Up', dict = 'anim@mp_player_intup', anim = 'idle_a' },
        { label = 'Dance', dict = 'anim@mp_player_intcelebrationmale@wave', anim = 'wave' }
    }
}

local function stopAnimation()
    local playerPed = PlayerPedId()

    ClearPedTasks(playerPed)
    ClearPedSecondaryTask(playerPed)
    StopAnimTask(playerPed, '', '', 1.0)

    currentAnimation = nil
end

local function playAnimation(dict, anim, flag)
    local playerPed = PlayerPedId()

    RequestAnimDict(dict)

    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end

    TaskPlayAnim(playerPed, dict, anim, 8.0, -8.0, -1, flag or 49, 0, false, false, false)

    currentAnimation = {
        dict = dict,
        anim = anim,
        flag = flag or 49
    }
end

local function playWalkAnimation(index)
    local animation = Animations.walk[index]

    if not animation then
        return
    end

    local playerPed = PlayerPedId()

    RequestAnimSet(animation.dict)

    while not HasAnimSetLoaded(animation.dict) do
        Wait(0)
    end

    SetPedMovementClipset(playerPed, animation.dict, true)

    currentAnimation = {
        type = 'walk',
        dict = animation.dict
    }
end

RegisterCommand('anim', function(source, args)
    local category = args[1]
    local index = tonumber(args[2]) or 1

    if not category then
        QBCore.Functions.Notify('Usage: /anim [walk|smoking|drinking|gestures] [number]', 'error')
        return
    end

    local animations = Animations[category]

    if not animations then
        QBCore.Functions.Notify('Unknown animation category', 'error')
        return
    end

    if category == 'walk' then
        playWalkAnimation(index)
    else
        local animation = animations[index]

        if not animation then
            QBCore.Functions.Notify('Animation not found', 'error')
            return
        end

        playAnimation(animation.dict, animation.anim, 49)
    end
end, false)

RegisterCommand('stopanim', function()
    stopAnimation()
end, false)

RegisterCommand('animlist', function()
    QBCore.Functions.Notify('Animations: /anim walk, /anim smoking, /anim drinking, /anim gestures', 'primary')
end, false)

CreateThread(function()
    while true do
        Wait(0)

        if IsControlJustReleased(0, 73) then
            stopAnimation()
        end
    end
end)