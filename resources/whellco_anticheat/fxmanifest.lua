fx_version 'cerulean'
game 'gta5'

author 'Chris Wheller'
description 'Adaptive QBCore anti-cheat and integrity monitoring system'
version '1.0.0'

server_script 'server.lua'
shared_script 'config.lua'

dependencies {
    'qb-core',
    'oxmysql'
}
