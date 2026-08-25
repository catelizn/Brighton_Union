-- Отключаем штатный qb-hud, чтобы вместо него работал HUD Brighton Union
CreateThread(function()
    for i = 1, 30 do
        Wait(1000)
        if GetResourceState('qb-hud') == 'started' then
            StopResource('qb-hud')
            break
        end
    end
end)
