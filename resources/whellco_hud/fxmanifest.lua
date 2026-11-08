fx_version 'cerulean'
game 'gta5'

author 'Chris Wheller'
description 'QBCore-compatible customizable HUD'
version '1.0.0'

client_script 'client.lua'
server_script 'server.lua'
shared_script 'config.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/app.js',
    'html/styles.css'
}

dependencies {
    'qb-core'
}
