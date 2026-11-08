Config = {}

Config.PlaylistUrl = 'https://raw.githubusercontent.com/TeamTYHBoss/IPTV/refs/heads/main/IPTV.m3u8'

Config.TVs = {
    {
        id = 'apartment_tv_1',
        label = 'Apartment TV',
        coords = vector3(-268.0, -955.0, 31.0),
        heading = 250.0,
        screenOffset = vector3(0.0, 0.0, 1.0)
    },
    {
        id = 'house_tv_1',
        label = 'House TV',
        coords = vector3(-268.0, -955.0, 31.0),
        heading = 250.0,
        screenOffset = vector3(0.0, 0.0, 1.0)
    }
}

Config.Controls = {
    interact = 38,
    nextChannel = 175,
    previousChannel = 174,
    closeTv = 177
}

Config.InteractDistance = 2.0