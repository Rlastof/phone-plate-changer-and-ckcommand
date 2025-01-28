fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'Plaka Değiştir'
author 'Rlastof'
description 'Plaka Değiştirme Aracı'
version '1.0.0'

dependencies {
    'qb-core',
    'ox_lib',
    'ox_inventory'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

shared_scripts {
    '@ox_lib/init.lua'
}
