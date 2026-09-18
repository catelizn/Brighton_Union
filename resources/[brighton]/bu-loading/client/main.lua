-- Тема загрузки: 'asphalt' (по умолчанию) или 'brooklyn'.
-- Меняется в server.cfg: setr bu_loading_theme 'brooklyn'
local theme = GetConvar('bu_loading_theme', 'asphalt')

CreateThread(function()
    SendLoadingScreenMessage(json.encode({ type = 'init', theme = theme }))
end)

-- Экран закрывается вручную из bu-auth: пока форма авторизации не отрисована,
-- лоадер остаётся. Запасной таймаут на две минуты страхует от белого экрана,
-- если NUI почему-то не ответит.
SetTimeout(120000, function()
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    SendLoadingScreenMessage(json.encode({ action = 'hide' }))
end)
