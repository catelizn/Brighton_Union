-- Тема загрузки: 'asphalt' (по умолчанию) или 'brooklyn'.
-- Меняется в server.cfg: setr bu_loading_theme 'brooklyn'
local theme = GetConvar('bu_loading_theme', 'asphalt')

CreateThread(function()
    SendNUIMessage({
        type = 'init',
        theme = theme,
        maxClients = tonumber(GetConvar('sv_maxclients', '48')) or 48
    })
end)
