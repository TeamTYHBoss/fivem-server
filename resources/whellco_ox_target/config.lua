Config = {}

Config.Debug = false

Config.VisualFeedback = {
    enabled = true,
    highlightColor = { 0, 150, 255 },
    highlightAlpha = 120,
    highlightDistance = 2.5,
    successSound = 'SELECT',
    successSoundSet = 'HUD_FRONTEND_DEFAULT_SOUNDSET',
    errorSound = 'ERROR',
    errorSoundSet = 'HUD_FRONTEND_DEFAULT_SOUNDSET'
}

Config.Targets = {
    ['police_armory'] = {
        type = 'model',
        model = `prop_amb_clinic_01`,
        label = 'Police Armory',
        icon = 'fa-solid fa-shield-halved',
        distance = 2.5,
        requiredJob = 'police',
        jobGrade = 2,
        event = 'whellco_ox_target:openArmory',
        feedback = {
            icon = 'fa-solid fa-shield-halved',
            color = '#0096ff',
            sound = 'SELECT'
        }
    },
    ['vehicle_repair'] = {
        type = 'vehicle',
        label = 'Repair Vehicle',
        icon = 'fa-solid fa-screwdriver-wrench',
        distance = 3.0,
        requiredJob = 'mechanic',
        jobGrade = 0,
        event = 'whellco_ox_target:repairVehicle',
        feedback = {
            icon = 'fa-solid fa-screwdriver-wrench',
            color = '#ffb400',
            sound = 'SELECT'
        }
    },
    ['npc_mechanic'] = {
        type = 'ped',
        model = `s_m_m_autoshop_01`,
        label = 'Talk to Mechanic',
        icon = 'fa-solid fa-comments',
        distance = 2.0,
        requiredJob = nil,
        jobGrade = 0,
        event = 'whellco_ox_target:talkToMechanic',
        feedback = {
            icon = 'fa-solid fa-comments',
            color = '#00c853',
            sound = 'SELECT'
        }
    },
    ['stash_box'] = {
        type = 'zone',
        coords = vector3(-1276.2, 295.1, 65.9),
        size = vector3(1.5, 1.5, 1.5),
        rotation = 0.0,
        label = 'Open Stash',
        icon = 'fa-solid fa-box',
        distance = 2.0,
        requiredJob = nil,
        jobGrade = 0,
        event = 'whellco_ox_target:openStash',
        feedback = {
            icon = 'fa-solid fa-box',
            color = '#9c27b0',
            sound = 'SELECT'
        }
    }
}