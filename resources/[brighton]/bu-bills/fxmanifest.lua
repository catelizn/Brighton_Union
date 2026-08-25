fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Brighton Union'
description 'Utility bills for owned properties (Brighton Union)'
version '1.0.0'

server_scripts {
    'server/main.lua'
}

shared_scripts {
    '@oxmysql/lib/MySQL.lua'
}

dependencies {
    'qb-core',
    'oxmysql'
}
