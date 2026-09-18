fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Brighton Union'
description 'Pets for Brighton Union'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'qb-core',
    'bu-interact',
    'oxmysql'
}
