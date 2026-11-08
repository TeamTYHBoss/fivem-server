fx_version 'cerulean'
game 'gta5'

author 'Chris Wheller'
description 'Fading red vignette effect with heartbeat'
version '1.0.0'

client_script 'client.lua'
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

dependencies {
    'qb-core',
    'whellco_dynamic_heartbeat'
}
