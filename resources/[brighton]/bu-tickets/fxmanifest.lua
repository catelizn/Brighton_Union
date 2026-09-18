fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Brighton Union'
description 'Support tickets for Brighton Union'
version '1.0.0'

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'qb-core',
    'oxmysql'
}
