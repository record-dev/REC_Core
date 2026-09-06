
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

version '0.2.0'
author 'Ⓒ RE:CORD | @Nazu'
description 'Ⓒ RE:CORD Core'

dependencies {
    'REC_Library',
    'oxmysql',
}

---[[
---     Every file is listed by hand so nothing outside this list is ever loaded.
---     The order is the dependency order: a file only requires what is above it.
---     The bridge files are the only place REC_Library's lib is called from.
---]]
shared_script {
    '@REC_Library/init.lua',
    'config/sh_config.lua',
    'config/sh_jobs.lua',
    'config/sh_gangs.lua',
    'locales/*.lua',
    'shared/sh_enum.lua',
    'shared/sh_functions.lua',
    'shared/sh_event.lua',
    'shared/sh_groups.lua',
}

client_scripts {
    'client/cl_bridge.lua',
    'client/cl_utils.lua',
    'handler/cl_handler.lua',
    'client/manager/cl_sessionManager.lua',
    'client/modules/cl_spawn.lua',
    'client/modules/cl_characterMenu.lua',
    'client/cl_main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config/sv_config.lua',
    'server/sv_bridge.lua',
    'server/sv_utils.lua',
    'handler/sv_handler.lua',
    'server/sv_schema.lua',
    'server/sv_repository.lua',
    'server/class/sv_character.lua',
    'server/manager/sv_serverManager.lua',
    'server/modules/sv_players.lua',
    'server/modules/sv_money.lua',
    'server/modules/sv_groups.lua',
    'server/modules/sv_data.lua',
    'server/sv_exports.lua',
    'server/sv_commands.lua',
    'server/sv_main.lua',
}
