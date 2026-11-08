fx_version 'cerulean'
game 'gta5'

author 'Chris Wheller'
description 'QBCore-native vehicle impound system'
version '2.0.0'

shared_script 'config.lua'

server_script '@oxmysql/lib/MySQL.lua'
server_script 'server.lua'

client_script 'client.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

dependencies {
    'qb-core',
    'oxmysql',
    'whellco_qbcore'
}
