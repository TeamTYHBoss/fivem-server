Config = {}

Config.Debug = false

Config.Targets = {
    ['police_armory'] = {
        type = 'model',
        model = `prop_amb_clinic_01`,
        label = 'Police Armory',
        icon = 'fa-solid fa-shield-halved',
        distance = 2.5,
        requiredJob = 'police',
        jobGrade = 2,
        event = 'whellco_ox_target:openArmory'
    },
    ['vehicle_repair'] = {
        type = 'vehicle',
        label = 'Repair Vehicle',
        icon = 'fa-solid fa-screwdriver-wrench',
        distance = 3.0,
        requiredJob = 'mechanic',
        jobGrade = 0,
        event = 'whellco_ox_target:repairVehicle'
    },
    ['npc_mechanic'] = {
        type = 'ped',
        model = `s_m_m_autoshop_01`,
        label = 'Talk to Mechanic',
        icon = 'fa-solid fa-comments',
        distance = 2.0,
        requiredJob = nil,
        jobGrade = 0,
        event = 'whellco_ox_target:talkToMechanic'
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
        event = 'whellco_ox_target:openStash'
    }
}