fx_version 'cerulean'
game 'gta5'

author 'Sairon'
description 'Plaka, Telefon Numarası Değiştirme ve CK'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@qb-core/shared/locale.lua',
    'shared/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

dependencies {
    'qb-core',
    'oxmysql',
    'ox_lib'
}

