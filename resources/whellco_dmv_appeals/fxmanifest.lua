fx_version 'cerulean'
game 'gta5'

author 'Chris Wheller'
description 'QBCore-compatible DMV appeal and community service system'
version '1.0.0'

client_script 'client.lua'
server_script 'server.lua'
shared_script 'config.lua'

dependencies {
    'qb-core',
    'oxmysql',
    'whellco_traffic_fines',
    'whellco_license_suspension'
}
