Config = {}

Config.Debug = false

-- Uniforms are intentionally generic and roleplay-focused.
-- Do not include real-world agency insignia, logos, or branded assets unless properly licensed.
Config.Uniforms = {
    police = {
        label = 'Police Uniform',
        requiredJob = 'police',
        requiredGrade = 0,
        male = {
            tshirt = 58,
            torso = 55,
            decals = 0,
            arms = 41,
            pants = 25,
            shoes = 25,
            hat = -1,
            glasses = -1
        },
        female = {
            tshirt = 35,
            torso = 48,
            decals = 0,
            arms = 44,
            pants = 34,
            shoes = 27,
            hat = -1,
            glasses = -1
        }
    },
    fire = {
        label = 'Firefighter Uniform',
        requiredJob = 'fire',
        requiredGrade = 0,
        male = {
            tshirt = 15,
            torso = 282,
            decals = 0,
            arms = 85,
            pants = 36,
            shoes = 25,
            hat = -1,
            glasses = -1
        },
        female = {
            tshirt = 15,
            torso = 355,
            decals = 0,
            arms = 85,
            pants = 34,
            shoes = 27,
            hat = -1,
            glasses = -1
        }
    },
    ems = {
        label = 'EMS Uniform',
        requiredJob = 'ambulance',
        requiredGrade = 0,
        male = {
            tshirt = 15,
            torso = 250,
            decals = 0,
            arms = 85,
            pants = 36,
            shoes = 25,
            hat = -1,
            glasses = -1
        },
        female = {
            tshirt = 15,
            torso = 323,
            decals = 0,
            arms = 85,
            pants = 34,
            shoes = 27,
            hat = -1,
            glasses = -1
        }
    }
}

Config.Vehicles = {
    police = {
        label = 'Police Cruiser',
        model = `police`,
        requiredJob = 'police',
        requiredGrade = 0,
        livery = 0
    },
    fire = {
        label = 'Fire Rescue Truck',
        model = `firetruk`,
        requiredJob = 'fire',
        requiredGrade = 0,
        livery = 0
    },
    ems = {
        label = 'EMS Ambulance',
        model = `ambulance`,
        requiredJob = 'ambulance',
        requiredGrade = 0,
        livery = 0
    }
}

Config.WardrobeCategories = {
    casual = {
        label = 'Casual',
        requiredJob = nil,
        outfits = {
            { label = 'Streetwear', male = { tshirt = 0, torso = 0, arms = 0, pants = 0, shoes = 0 }, female = { tshirt = 0, torso = 0, arms = 0, pants = 0, shoes = 0 } },
            { label = 'Formal', male = { tshirt = 0, torso = 4, arms = 0, pants = 0, shoes = 0 }, female = { tshirt = 0, torso = 4, arms = 0, pants = 0, shoes = 0 } }
        }
    },
    emergency = {
        label = 'Emergency Services',
        requiredJob = nil,
        outfits = {
            { label = 'Police Uniform', uniform = 'police' },
            { label = 'Firefighter Uniform', uniform = 'fire' },
            { label = 'EMS Uniform', uniform = 'ems' }
        }
    }
}