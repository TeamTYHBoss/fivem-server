fx_version 'cerulean'
game 'gta5'

author 'TeamTYHBoss'
description 'Computer system with bank, shop, marketplace, transfers, notifications, and social media'
version '1.1.0'

dependency 'qb-core'
dependency 'oxmysql'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

lua54 'yes'