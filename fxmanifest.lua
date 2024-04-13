fx_version "cerulean"
game "gta5"
version '0.0.1'
author 'github.com/Mystro69'
lua54 'yes'

shared_scripts {
    "config.lua"
}


dependencies {
    'PolyZone',
    'ox_lib'
}

client_scripts {
    '@ox_lib/init.lua',
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/client.lua'
}

server_scripts {
    'server/server.lua'
}