fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Brighton Union'
description 'Driving and flight school with exams (Brighton Union)'
version '1.0.0'

shared_scripts {
    'config.lua',
    '@oxmysql/lib/MySQL.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}

dependencies {
    'qb-core',
    'bu-interact',
    'qb-vehiclekeys',
    'oxmysql'
}
