fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'Plaka Değiştir'
author 'Rlastof'
description 'Plaka Değiştirme Aracı'
version '1.0.0'

-- Dependency Tanımları
dependencies {
    'qb-core',        -- QBCore Framework
    'ox_lib',         -- OXLib Menü ve Input
    'ox_inventory'    -- OX Inventory
}

-- Client/Server Scriptler
client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

shared_scripts {
    '@ox_lib/init.lua' -- OXLib fonksiyonları için
}
