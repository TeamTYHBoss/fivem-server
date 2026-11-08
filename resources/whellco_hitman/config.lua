Config = {}

Config.Debug = false

Config.Hitman = {
    JobName = 'hitman',
    ContractTimeSeconds = 600,
    MaxActiveContracts = 1,
    ContractCooldownSeconds = 60,
    NpcTargetModel = 'a_m_m_business_01',
    NpcTargetHealth = 200,
    NpcTargetArmour = 50,
    NpcTargetWeapon = 'WEAPON_PISTOL',
    NpcTargetAccuracy = 25,
    NpcTargetFleeDistance = 150.0,
    EscapeDistance = 200.0
}

-- Contracts escalate by tier. Payouts increase, but the time limit stays constant.
Config.ContractTiers = {
    {
        tier = 1,
        label = 'Low-profile target',
        payout = 2500,
        npcCount = 1,
        npcArmour = 0,
        npcWeapon = 'WEAPON_UNARMED'
    },
    {
        tier = 2,
        label = 'Protected target',
        payout = 5000,
        npcCount = 2,
        npcArmour = 25,
        npcWeapon = 'WEAPON_PISTOL'
    },
    {
        tier = 3,
        label = 'High-value target',
        payout = 10000,
        npcCount = 3,
        npcArmour = 50,
        npcWeapon = 'WEAPON_PISTOL'
    },
    {
        tier = 4,
        label = 'High-risk operation',
        payout = 20000,
        npcCount = 4,
        npcArmour = 75,
        npcWeapon = 'WEAPON_SMG'
    },
    {
        tier = 5,
        label = 'Maximum-risk operation',
        payout = 40000,
        npcCount = 5,
        npcArmour = 100,
        npcWeapon = 'WEAPON_SMG'
    }
}

Config.Appearance = {
    HitmanSkin = {
        model = 'mp_m_freemode_01',
        drawable = 11,
        texture = 0
    },
    NeckBarcode = {
        tattooCollection = 'mpbusiness_overlays',
        tattooName = 'FM_Overlays_Torso',
        label = 'Barcode neck marking'
    }
}

Config.AdminJobs = {
    admin = true,
    manager = true
}