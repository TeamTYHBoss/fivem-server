fx_version 'cerulean'
game 'gta5'

author 'Chris Wheller'
description 'Immersive jobs, shops, transport, services and world events'
version '1.1.0'

shared_script 'config.lua'

server_script '@oxmysql/lib/MySQL.lua'
server_script 'server.lua'

client_script 'client.lua'

dependency 'oxmysql'
