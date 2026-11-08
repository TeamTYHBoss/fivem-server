Config = {}

Config.Debug = false

Config.SecurityJob = 'security'
Config.ScanCooldownSeconds = 10
Config.FakeIdChance = 25

Config.Entrance = {
    label = 'Club Entrance',
    location = vector3(127.3, -1299.9, 29.3),
    radius = 5.0
}

Config.IdItems = {
    id_card = {
        label = 'ID Card',
        valid = true
    },
    fake_id = {
        label = 'Fake ID',
        valid = false
    }
}