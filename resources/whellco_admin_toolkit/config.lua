Config = {}

Config.Debug = false

Config.AdminJobs = {
    admin = true,
    manager = true
}

Config.AdminPermissions = {
    godmode = { 'admin' },
    invisibility = { 'admin' },
    teleport = { 'admin', 'manager' },
    inventory = { 'admin', 'manager' },
    heal = { 'admin', 'manager' },
    revive = { 'admin', 'manager' },
    freeze = { 'admin' },
    spectate = { 'admin', 'manager' }
}

Config.CommandCooldownSeconds = 3