Config = {}

Config.Debug = false

Config.CurrencySymbol = '$'
Config.RoomCooldownSeconds = 30
Config.DanceDuration = 45

Config.VipRooms = {
    ['vip_1'] = {
        label = 'VIP Room 1',
        location = vector3(135.0, -1310.0, 29.3),
        radius = 5.0,
        price = 2500,
        animations = {
            customer = 'anim@amb@nightclub@mini@dance@dance_step@',
            dancer = 'anim@amb@nightclub@mini@dance@dance_step@'
        }
    },
    ['vip_2'] = {
        label = 'VIP Room 2',
        location = vector3(140.0, -1312.0, 29.3),
        radius = 5.0,
        price = 3500,
        animations = {
            customer = 'anim@amb@nightclub@mini@dance@dance_step@',
            dancer = 'anim@amb@nightclub@mini@dance@dance_step@'
        }
    }
}