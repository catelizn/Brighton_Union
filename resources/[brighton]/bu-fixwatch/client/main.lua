-- Brighton Union watchdog: снимаем нативный загрузочный экран FiveM
-- (чёрный оверлей с «M / Esc — закрыть») и застрявшее затемнение.

local fadedTicks = 0

-- Нативный лоадер закрывает bu-auth: сначала ждём готовности формы авторизации,
-- поэтому до прохождения входа трогать его нельзя, иначе между экранами мигает
-- город. После авторизации вызовы безвредны и снимают застрявший оверлей.
CreateThread(function()
    while true do
        if LocalPlayer.state.buAuthed then
            ShutdownLoadingScreen()
            ShutdownLoadingScreenNui()
        end
        Wait(250)
    end
end)

CreateThread(function()
    while true do
        Wait(1000)

        -- Застрявшее затемнение: экран уже чёрный дольше 5 секунд -> снимаем.
        -- Исключение: авторизация и выбор персонажа держат затемнение намеренно
        -- (bu-auth / buSelecting) — принудительный fade-in там только мигал бы миром.
        if IsScreenFadedOut() then
            local holding = LocalPlayer.state.buSelecting == true
                or (GetResourceState('bu-auth') == 'started' and LocalPlayer.state.buAuthed ~= true)
            if holding then
                fadedTicks = 0
            else
                fadedTicks = fadedTicks + 1
                if fadedTicks > 5 then
                    DoScreenFadeIn(400)
                    fadedTicks = 0
                end
            end
        else
            fadedTicks = 0
        end
    end
end)
