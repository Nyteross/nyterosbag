fx_version 'cerulean'
games {'gta5'}

shared_script '@es_extended/imports.lua'


--Chargement LIB RageUI

client_scripts {
    "src/client/RMenu.lua",
    "src/client/menu/RageUI.lua",
    "src/client/menu/Menu.lua",
    "src/client/menu/MenuController.lua",

    "src/client/components/*.lua",

    "src/client/menu/elements/*.lua",

    "src/client/menu/items/*.lua",

    "src/client/menu/panels/*.lua",

    "src/client/menu/windows/*.lua",

}



client_scripts {
    "client.lua",
    "config.lua",
    "menu.lua",
    "utils/*.lua",
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    "config.lua",
    "server.lua",
    "utils/*.lua",

}