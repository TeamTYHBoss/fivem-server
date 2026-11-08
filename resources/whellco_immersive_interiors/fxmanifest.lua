fx_version 'cerulean'
game 'gta5'

author 'Chris Wheller'
description 'QBCore-native immersive interiors, MLO streaming and interactive spaces'
version '1.0.0'

client_script 'client.lua'
server_script 'server.lua'
shared_script 'config.lua'

files {
    'stream/**/*.ytd',
    'stream/**/*.ydr',
    'stream/**/*.ydd',
    'stream/**/*.ybn',
    'stream/**/*.ymap'
}

this_is_a_map 'yes'

dependencies {
    'qb-core'
}
