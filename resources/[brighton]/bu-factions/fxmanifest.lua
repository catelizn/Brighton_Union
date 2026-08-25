fx_version 'cerulean'
game 'gta5'

author 'Brighton Union'
description 'Faction bases: interiors, spawns, stash, wardrobe, gang and mafia quests'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'qb-core',
    'qb-interior',
    'qb-inventory',
    'qb-clothing',
    'bu-interact'
}
