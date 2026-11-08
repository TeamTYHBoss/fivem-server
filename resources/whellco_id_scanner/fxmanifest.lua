fx_version 'cerulean'
game 'gta5'

author 'Chris Wheller'
description 'Fake ID scanner for club security at entrance'
version '1.0.0'

client_script 'client.lua'
server_script 'server.lua'
shared_script 'config.lua'

dependencies {
    'qb-core',
    'oxmysql'
}
