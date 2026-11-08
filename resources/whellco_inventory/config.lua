Config = {}

Config.Debug = false

Config.DefaultPlayerSlots = 40
Config.MaxItemStack = 100

Config.StorageTypes = {
    ['trunk'] = {
        label = 'Vehicle Trunk',
        slots = 50,
        weight = 100000,
        requiresOwnership = true
    },
    ['glovebox'] = {
        label = 'Glovebox',
        slots = 15,
        weight = 25000,
        requiresOwnership = true
    },
    ['house'] = {
        label = 'House Storage',
        slots = 100,
        weight = 250000,
        requiresOwnership = true
    },
    ['stash'] = {
        label = 'Stash',
        slots = 50,
        weight = 100000,
        requiresOwnership = false
    },
    ['ground'] = {
        label = 'Ground Drop',
        slots = 20,
        weight = 50000,
        requiresOwnership = false,
        expireMinutes = 30
    }
}

Config.AllowedItems = {
    water = { label = 'Water', weight = 500, stackable = true },
    sandwich = { label = 'Sandwich', weight = 500, stackable = true },
    phone = { label = 'Phone', weight = 250, stackable = false },
    lockpick = { label = 'Lockpick', weight = 300, stackable = true },
    repairkit = { label = 'Repair Kit', weight = 2000, stackable = true }
}