Config = {}

Config.Debug = false

Config.MaxAccessoriesPerWeapon = 4
Config.InstallCost = 500
Config.RemoveCost = 250

Config.Accessories = {
    suppressor = {
        label = 'Suppressor',
        component = 'COMPONENT_AT_AR_SUPP_02',
        compatibleWeapons = {
            'WEAPON_PISTOL',
            'WEAPON_COMBATPISTOL',
            'WEAPON_APPISTOL',
            'WEAPON_CARBINERIFLE'
        },
        effects = {
            accuracy = 5,
            recoil = -5
        }
    },
    flashlight = {
        label = 'Flashlight',
        component = 'COMPONENT_AT_PI_FLSH',
        compatibleWeapons = {
            'WEAPON_PISTOL',
            'WEAPON_COMBATPISTOL',
            'WEAPON_APPISTOL',
            'WEAPON_CARBINERIFLE'
        },
        effects = {
            accuracy = 2
        }
    },
    extended_clip = {
        label = 'Extended Clip',
        component = 'COMPONENT_PISTOL_CLIP_02',
        compatibleWeapons = {
            'WEAPON_PISTOL',
            'WEAPON_COMBATPISTOL',
            'WEAPON_APPISTOL'
        },
        effects = {
            magazine = 12
        }
    },
    grip = {
        label = 'Grip',
        component = 'COMPONENT_AT_AR_AFGRIP',
        compatibleWeapons = {
            'WEAPON_CARBINERIFLE',
            'WEAPON_ADVANCEDRIFLE'
        },
        effects = {
            recoil = -8,
            accuracy = 3
        }
    },
    scope = {
        label = 'Scope',
        component = 'COMPONENT_AT_SCOPE_MEDIUM',
        compatibleWeapons = {
            'WEAPON_CARBINERIFLE',
            'WEAPON_ADVANCEDRIFLE'
        },
        effects = {
            accuracy = 10,
            range = 15
        }
    }
}