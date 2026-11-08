Config = {}

Config.UpdateInterval = 500
Config.SaveInterval = 30

Config.Hud = {
    health = { enabled = true, position = 'bottom-left', color = '#22c55e' },
    armor = { enabled = true, position = 'bottom-left', color = '#3b82f6' },
    stamina = { enabled = true, position = 'bottom-left', color = '#f59e0b' },
    hunger = { enabled = true, position = 'bottom-left', color = '#eab308' },
    thirst = { enabled = true, position = 'bottom-left', color = '#38bdf8' },
    stress = { enabled = true, position = 'bottom-left', color = '#ef4444' },
    oxygen = { enabled = true, position = 'bottom-left', color = '#06b6d4' },
    minimap = {
        enabled = true,
        position = 'bottom-left',
        width = 0.170,
        height = 0.230,
        shape = 'square'
    }
}

Config.LayoutPresets = {
    default = {
        health = 'bottom-left',
        armor = 'bottom-left',
        stamina = 'bottom-left',
        hunger = 'bottom-left',
        thirst = 'bottom-left',
        stress = 'bottom-left',
        oxygen = 'bottom-left',
        minimap = 'bottom-left'
    },
    compact = {
        health = 'bottom-right',
        armor = 'bottom-right',
        stamina = 'bottom-right',
        hunger = 'bottom-right',
        thirst = 'bottom-right',
        stress = 'bottom-right',
        oxygen = 'bottom-right',
        minimap = 'bottom-right'
    }
}