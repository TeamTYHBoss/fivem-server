fx_version 'cerulean'
game 'gta5'

author 'Chris Wheller'
description 'Disguised entry mechanic with suspicion meter, guard challenges, and access logs'
version '1.1.0'

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
