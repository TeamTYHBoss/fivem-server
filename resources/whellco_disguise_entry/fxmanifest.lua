fx_version 'cerulean'
game 'gta5'

author 'Chris Wheller'
description 'Disguised entry mechanic for restricted areas with detection, cooldowns, and access logs'
version '1.0.0'

client_script 'client.lua'
server_script 'server.lua'
shared_script 'config.lua'

dependencies {
    'qb-core',
    'oxmysql'
}
