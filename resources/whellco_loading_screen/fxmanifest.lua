fx_version 'cerulean'
game 'gta5'

author 'Chris Wheller'
description 'QBCore-compatible custom loading screen with audio and video support'
version '1.0.0'

loadscreen 'html/index.html'
loadscreen_manual_shutdown 'yes'

files {
    'html/index.html',
    'html/styles.css',
    'html/app.js',
    'html/media/audio.mp3',
    'html/media/video.mp4'
}

dependencies {
    'qb-core'
}
