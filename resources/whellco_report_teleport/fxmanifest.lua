fx_version 'cerulean'
game 'gta5'

author 'Chris Wheller'
description 'Teleport staff to the location of an open report'
version '1.0.0'

client_script 'client.lua'
server_script 'server.lua'
shared_script 'config.lua'

dependencies {
    'qb-core',
    'oxmysql',
    'whellco_player_reports'
}
