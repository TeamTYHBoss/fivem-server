fx_version 'cerulean'
game 'gta5'

author 'Chris Wheller'
description 'QBCore-compatible blacklist system for banned patrons'
version '1.0.0'

server_script 'server.lua'
shared_script 'config.lua'

dependencies {
    'qb-core',
    'oxmysql',
    'whellco_strip_club'
}
