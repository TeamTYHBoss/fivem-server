fx_version 'cerulean'
game 'gta5'

author 'Chris Wheller'
description 'Muffle other game audio when health is critical'
version '1.0.0'

client_script 'client.lua'
shared_script 'config.lua'

dependencies {
    'qb-core',
    'whellco_dynamic_heartbeat'
}
