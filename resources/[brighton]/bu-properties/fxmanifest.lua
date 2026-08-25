fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Brighton Union'
description 'Business properties purchase via marker (Brighton Union)'
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

dependencies {
    'qb-core',
    'bu-interact',
    'qb-menu',
    'qb-input',
    'oxmysql'
}
