fx_version 'cerulean'
game 'gta5'

author 'Chris Wheller'
description 'Lottery ticket scratch card minigame'
version '1.0.0'

client_script 'client.lua'
server_script 'server.lua'
shared_script 'config.lua'

dependencies {
    'qb-core',
    'oxmysql'
}
