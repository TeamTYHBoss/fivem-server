fx_version 'cerulean'
game 'gta5'

author 'Chris Wheller'
description 'In-game player reporting system with Discord webhook'
version '1.0.0'

client_script 'client.lua'
server_script 'server.lua'
shared_script 'config.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

dependencies {
    'qb-core',
    'oxmysql'
}
