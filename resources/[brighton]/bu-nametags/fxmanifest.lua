fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'catelizn'
description 'Brighton Union: name tags above players (acquaintance / faction / family)'

dependencies {
    'qb-core',
    'oxmysql'
}

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
