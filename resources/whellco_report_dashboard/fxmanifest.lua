fx_version 'cerulean'
game 'gta5'

author 'Chris Wheller'
description 'Report sound alerts and staff dashboard for player reports'
version '1.0.0'

client_script 'client.lua'
server_script 'server.lua'
shared_script 'config.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'sounds/report_alert.ogg'
}

dependencies {
    'qb-core',
    'oxmysql',
    'whellco_player_reports'
}
