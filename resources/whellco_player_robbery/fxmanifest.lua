fx_version 'cerulean'
game 'gta5'

author 'Chris Wheller'
description 'Player robbery minigame with proximity prompts and server-side validation'
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
