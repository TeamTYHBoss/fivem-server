fx_version 'cerulean'
game 'gta5'

author 'Chris Wheller'
description 'QBCore-compatible EUP, emergency vehicles and expanded wardrobe assets'
version '1.0.0'

client_script 'client.lua'
server_script 'server.lua'
shared_script 'config.lua'

files {
    'stream/**/*.ytd',
    'stream/**/*.ydr',
    'stream/**/*.ydd',
    'stream/**/*.yft',
    'stream/**/*.ytd',
    'stream/**/*.ynd',
    'stream/**/*.ytyp'
}

data_file 'AUDIO_GROUPS' 'stream/*/audio/*.dat'
data_file 'CONTENT_FILE_TYPES' 'stream/*/content.xml'
data_file 'VEHICLE_METADATA_FILE' 'stream/*/vehicles.meta'
data_file 'CARCOLS_FILE' 'stream/*/carcols.meta'
data_file 'VEHICLE_VARIATIONS_FILE' 'stream/*/vehvariations.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'stream/*/vehiclelayouts.meta'
data_file 'PED_METADATA_FILE' 'stream/*/peds.meta'

dependencies {
    'qb-core'
}
