fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Brighton Union'
description 'Radio (walkie-talkie) via pma-voice'
version '1.0.0'

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'qb-core',
    'pma-voice'
}
