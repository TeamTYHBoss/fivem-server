fx_version 'cerulean'
game 'gta5'

author 'Chris Wheller'
description 'Custom animated FiveM loading screen with music'
version '1.1.0'

loadscreen 'html/index.html'
loadscreen_cursor 'yes'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/music/theme.mp3'
}

client_script 'client.lua'
