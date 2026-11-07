fx_version 'cerulean'
game 'gta5'

author 'Chris Wheller'
description 'Character wardrobe and customization before spawning'
version '1.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

client_script 'client.lua'
server_script 'server.lua'

dependencies {
    'spawnmanager'
}
