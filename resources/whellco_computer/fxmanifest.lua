fx_version 'cerulean'
game 'gta5'

author 'TeamTYHBoss'
description 'Computer system with bank, shop, marketplace, transfers, notifications, and social media'
version '1.2.0'

dependency 'qb-core'
dependency 'oxmysql'
dependency 'whellco_utils'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/bank.lua',
    'server/shop.lua',
    'server/marketplace.lua',
    'server/social.lua',
    'server/notifications.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/state.js',
    'html/api.js',
    'html/render.js',
    'html/events.js'
}

lua54 'yes'
