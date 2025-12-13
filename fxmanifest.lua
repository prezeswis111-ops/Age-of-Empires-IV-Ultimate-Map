fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Your Name'
description 'ESX Advanced Heist System with OX Target, Animations & Minigames'
version '3.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua',
    -- Uncomment below for phone integration
    -- 'client/phone_integration.lua',
    -- 'client/usb_computer.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    -- Uncomment below for phone integration
    -- 'server/phone_integration.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html'
}
