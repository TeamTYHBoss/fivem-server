Config = {}

Config.Currency = '£'

Config.Jobs = {
    taxi = {
        label = 'Taxi Driver',
        description = 'Drive passengers around the city.',
        payout = 120,
        xp = 15,
        requiredLevel = 1,
        cooldown = 120000
    },
    delivery = {
        label = 'Delivery Driver',
        description = 'Deliver packages across the city.',
        payout = 150,
        xp = 20,
        requiredLevel = 2,
        cooldown = 150000
    },
    mechanic = {
        label = 'Mechanic',
        description = 'Repair and maintain vehicles.',
        payout = 180,
        xp = 25,
        requiredLevel = 3,
        cooldown = 180000
    },
    garbage = {
        label = 'Garbage Collector',
        description = 'Collect and dispose of waste.',
        payout = 100,
        xp = 12,
        requiredLevel = 1,
        cooldown = 90000
    }
}

Config.JobCenter = {
    coords = vector3(215.0, -810.0, 30.0)
}
