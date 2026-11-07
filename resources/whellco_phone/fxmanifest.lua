fx_version 'cerulean'
game 'gta5'

author 'Chris Wheller'
description 'Phone system with contacts, messages, calls and phone NUI'
version '1.0.0'

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

dependency 'oxmysql'
