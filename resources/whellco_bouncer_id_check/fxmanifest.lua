fx_version 'cerulean'
game 'gta5'

author 'Chris Wheller'
description 'Bouncer ID check at the front door'
version '1.0.0'

client_script 'client.lua'
server_script 'server.lua'
shared_script 'config.lua'

dependencies {
    'qb-core',
    'oxmysql',
    'whellco_strip_club'
}
