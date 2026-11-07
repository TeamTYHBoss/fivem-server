fx_version 'cerulean'
game 'gta5'

author 'Chris Wheller'
description 'Persistent economy, banking, XP, levels, shops, jobs, receipts and HUD'
version '1.2.0'

shared_script 'config.lua'

server_script '@oxmysql/lib/MySQL.lua'
server_script 'server.lua'

client_script 'client.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/jobboard.html',
    'html/jobboard.css',
    'html/jobboard.js',
    'html/hud.html',
    'html/hud.css',
    'html/hud.js'
}

dependency 'oxmysql'
