
--[[
--
--                       ________ __________      ________________ ________ ________                
--                       ___  __ \___  ____/_____ __  ____/__  __ \___  __ \___  __ \               
--        ________       __  /_/ /__  __/   ___(_)_  /     _  / / /__  /_/ /__  / / /       ________
--        _/_____/       _  _, _/ _  /___   ___   / /___   / /_/ / _  _, _/ _  /_/ /        _/_____/
--                       /_/ |_|  /_____/   _(_)  \____/   \____/  /_/ |_|  /_____/                 
--                                                                                                  
---]]

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

version 'v0.0.0'
author 'Ⓒ RE:CORD | @Nazu'
description 'Core Script'

dependencies {
    'ox_lib',
    'REC_Library',
    'REC_PlayerManager',
}

shared_script {
    '@ox_lib/init.lua',
    'config/sh_config.lua',
    'locales/*.lua',
    'shared/*.lua',
}

client_scripts {
    'handler/cl_handler.lua',
    'client/manager/*.lua',
    'client/*.lua'
}

server_scripts {
    -- '@oxmysql/lib/MySQL.lua',
    'config/sv_config.lua',
    'handler/sv_handler.lua',
    'server/manager/*.lua',
    'server/*.lua',
}

escrow_ignore {
    'config/*.lua',
    'handler/*.lua',
    'locales/*.lua',
    'client/cl_utils.lua',
    'client/manager/*.lua',
    'server/sv_utils.lua',
    'server/manager/*.lua',
    'shared/*.lua',
    'annotations.lua',
}