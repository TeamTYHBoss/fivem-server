fx_version 'cerulean'
game 'gta5'

author 'Chris Wheller'
description 'QBCore-native character appearance and wardrobe'
version '2.0.0'

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
    'oxmysql'
}
