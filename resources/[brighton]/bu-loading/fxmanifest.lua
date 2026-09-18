fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Brighton Union'
description 'Custom loading screen with switchable themes (Brighton Union)'
version '1.0.0'

loadscreen_manual_shutdown 'yes'

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

loadscreen 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'html/images/background.jpg',
    'html/images/setka.png'
}
